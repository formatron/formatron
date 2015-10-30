require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation/template'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      # rubocop:disable Metrics/ModuleLength
      module CloudFormation
        describe Template do
          describe '::create' do
            before :each do
              @description = 'description'
            end

            it 'should return an empty template' do
              expect(Template.create(@description)).to eql(
                AWSTemplateFormatVersion: '2010-09-09',
                Description: "#{@description}"
              )
            end
          end

          describe '::add_vpc' do
            before :each do
              @cidr = 'cidr'
              @subnets = {
                subnet1: 'subnet1',
                subnet2: 'subnet2',
                subnet3: 'subnet3'
              }
              @vpc = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::VPC'
              )
              allow(@vpc).to receive(:cidr) { @cidr }
              allow(@vpc).to receive(:subnets) { @subnets }
              allow(Template).to receive(
                :add_subnet
              ) do |template:, name:, subnet:|
                template["#{name}Subnet".to_sym] = subnet
              end
            end

            it 'should add the VPC resources to the template' do
              template = {}
              Template.add_vpc(
                template: template,
                vpc: @vpc
              )
              expect(template).to eql(
                subnet1Subnet: @subnets[:subnet1],
                subnet2Subnet: @subnets[:subnet2],
                subnet3Subnet: @subnets[:subnet3],
                Resources: {
                  vpc: {
                    Type: 'AWS::EC2::VPC',
                    Properties: {
                      CidrBlock: @cidr,
                      EnableDnsSupport: true,
                      EnableDnsHostnames: true,
                      InstanceTenancy: 'default'
                    }
                  },
                  internetGateway: {
                    Type: 'AWS::EC2::InternetGateway'
                  },
                  vpcGatewayAttachment: {
                    Type: 'AWS::EC2::VPCGatewayAttachment',
                    Properties: {
                      InternetGatewayId: { Ref: 'internetGateway' },
                      VpcId: { Ref: 'vpc' }
                    }
                  },
                  publicRouteTable: {
                    Type: 'AWS::EC2::RouteTable',
                    Properties: {
                      VpcId: { Ref: 'vpc' }
                    }
                  },
                  publicRoute: {
                    Type: 'AWS::EC2::Route',
                    DependsOn: 'vpcGatewayAttachment',
                    Properties: {
                      RouteTableId: { Ref: 'publicRouteTable' },
                      DestinationCidrBlock: '0.0.0.0/0',
                      GatewayId: { Ref: 'internetGateway' }
                    }
                  },
                  privateRouteTable: {
                    Type: 'AWS::EC2::RouteTable',
                    Properties: {
                      VpcId: { Ref: 'vpc' }
                    }
                  },
                  privateRoute: {
                    Type: 'AWS::EC2::Route',
                    Properties: {
                      RouteTableId: { Ref: 'privateRouteTable' },
                      DestinationCidrBlock: '0.0.0.0/0',
                      InstanceId: { Ref: 'natInstance' }
                    }
                  }
                },
                Outputs: {
                  vpc: {
                    Value: { Ref: 'vpc' }
                  }
                }
              )
            end
          end

          describe '::add_subnet' do
            before :each do
              @name = 'name'
              @availability_zone = 'availability_zone'
              @cidr = 'cidr'
              @subnet = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet'
              )
              allow(@subnet).to receive(
                :availability_zone
              ) { @availability_zone }
              allow(@subnet).to receive(:cidr) { @cidr }
            end

            context 'with a private subnet' do
              before :each do
                allow(@subnet).to receive(:public?) { false }
              end

              it 'should add the subnet resources to the template' do
                template = {}
                Template.add_subnet(
                  template: template,
                  name: @name,
                  subnet: @subnet
                )
                expect(template).to eql(
                  Resources: {
                    "#{@name}Subnet".to_sym => {
                      Type: 'AWS::EC2::Subnet',
                      Properties: {
                        VpcId: { Ref: 'vpc' },
                        CidrBlock: @cidr,
                        AvailabilityZone: @availability_zone
                      }
                    },
                    "#{@name}SubnetRouteTableAssociation".to_sym => {
                      Type: 'AWS::EC2::SubnetRouteTableAssociation',
                      Properties: {
                        RouteTableId: { Ref: 'privateRouteTable' },
                        SubnetId: { Ref: "#{@name}Subnet" }
                      }
                    }
                  },
                  Outputs: {
                    "#{@name}Subnet".to_sym => {
                      Value: { Ref: "#{@name}Subnet" }
                    }
                  }
                )
              end
            end

            context 'with a public subnet' do
              before :each do
                @acl = instance_double(
                  'Formatron::Configuration::Formatronfile::Bootstrap' \
                  '::VPC::Subnet::ACL'
                )
                allow(@subnet).to receive(:public?) { true }
                allow(@subnet).to receive(:acl) { @acl }
              end

              context 'without any ACL source IP rules' do
                before :each do
                  allow(@acl).to receive(:source_ips) { [] }
                end

                it 'should add the subnet resources to the template' do
                  template = {}
                  Template.add_subnet(
                    template: template,
                    name: @name,
                    subnet: @subnet
                  )
                  expect(template).to eql(
                    Resources: {
                      "#{@name}Subnet".to_sym => {
                        Type: 'AWS::EC2::Subnet',
                        Properties: {
                          VpcId: { Ref: 'vpc' },
                          CidrBlock: @cidr,
                          AvailabilityZone: @availability_zone
                        }
                      },
                      "#{@name}SubnetRouteTableAssociation".to_sym => {
                        Type: 'AWS::EC2::SubnetRouteTableAssociation',
                        Properties: {
                          RouteTableId: { Ref: 'publicRouteTable' },
                          SubnetId: { Ref: "#{@name}Subnet" }
                        }
                      }
                    },
                    Outputs: {
                      "#{@name}Subnet".to_sym => {
                        Value: { Ref: "#{@name}Subnet" }
                      }
                    }
                  )
                end
              end

              context 'with ACL source IP rules' do
                before :each do
                  @source_ips = [
                    '1.1.1.1',
                    '2.2.2.2'
                  ]
                  allow(@acl).to receive(:source_ips) { @sourceips }
                end

                skip 'should add the subnet resources to the template' do
                  template = {}
                  Template.add_subnet(
                    template: template,
                    name: @name,
                    subnet: @subnet
                  )
                  expect(template).to eql(
                    Resources: {
                      "#{@name}Subnet".to_sym => {
                        Type: 'AWS::EC2::Subnet',
                        Properties: {
                          VpcId: { Ref: 'vpc' },
                          CidrBlock: @cidr,
                          AvailabilityZone: @availability_zone
                        }
                      },
                      "#{@name}SubnetRouteTableAssociation".to_sym => {
                        Type: 'AWS::EC2::SubnetRouteTableAssociation',
                        Properties: {
                          RouteTableId: { Ref: 'publicRouteTable' },
                          SubnetId: { Ref: "#{@name}Subnet" }
                        }
                      }
                    },
                    Outputs: {
                      "#{@name}Subnet".to_sym => {
                        Value: { Ref: "#{@name}Subnet" }
                      }
                    }
                  )
                end
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end