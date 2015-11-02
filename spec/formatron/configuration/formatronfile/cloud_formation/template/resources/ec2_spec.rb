require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation' \
        '/template/resources/ec2'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
          # namespacing for tests
          # rubocop:disable Metrics/ModuleLength
          module Resources
            describe EC2 do
              describe '::vpc' do
                it 'should return a VPC resource' do
                  cidr = 'cidr'
                  expect(EC2.vpc(cidr: cidr)).to eql(
                    Type: 'AWS::EC2::VPC',
                    Properties: {
                      CidrBlock: cidr,
                      EnableDnsSupport: true,
                      EnableDnsHostnames: true,
                      InstanceTenancy: 'default'
                    }
                  )
                end
              end

              describe '::internet_gateway' do
                it 'should return an InternetGateway resource' do
                  expect(EC2.internet_gateway).to eql(
                    Type: 'AWS::EC2::InternetGateway'
                  )
                end
              end

              describe '::vpc_gateway_attachment' do
                it 'should return a VPCGatewayAttachment resource' do
                  vpc = 'vpc'
                  gateway = 'gateway'
                  expect(
                    EC2.vpc_gateway_attachment(
                      vpc: vpc,
                      gateway: gateway
                    )
                  ).to eql(
                    Type: 'AWS::EC2::VPCGatewayAttachment',
                    Properties: {
                      InternetGatewayId: { Ref: gateway },
                      VpcId: { Ref: vpc }
                    }
                  )
                end
              end

              describe '::route_table' do
                it 'should return a RouteTable resource' do
                  vpc = 'vpc'
                  expect(
                    EC2.route_table(
                      vpc: vpc
                    )
                  ).to eql(
                    Type: 'AWS::EC2::RouteTable',
                    Properties: {
                      VpcId: { Ref: vpc }
                    }
                  )
                end
              end

              describe '::route' do
                context 'with gateway' do
                  it 'should return a Route resource' do
                    route_table = 'route_table'
                    internet_gateway = 'internet_gateway'
                    vpc_gateway_attachment = 'vpc_gateway_attachment'
                    expect(
                      EC2.route(
                        vpc_gateway_attachment: vpc_gateway_attachment,
                        route_table: route_table,
                        internet_gateway: internet_gateway
                      )
                    ).to eql(
                      Type: 'AWS::EC2::Route',
                      DependsOn: vpc_gateway_attachment,
                      Properties: {
                        RouteTableId: { Ref: route_table },
                        DestinationCidrBlock: '0.0.0.0/0',
                        GatewayId: { Ref: internet_gateway }
                      }
                    )
                  end
                end

                context 'with instance' do
                  it 'should return a Route resource' do
                    route_table = 'route_table'
                    instance = 'instance'
                    expect(
                      EC2.route(
                        route_table: route_table,
                        instance: instance
                      )
                    ).to eql(
                      Type: 'AWS::EC2::Route',
                      Properties: {
                        RouteTableId: { Ref: route_table },
                        DestinationCidrBlock: '0.0.0.0/0',
                        InstanceId: { Ref: instance }
                      }
                    )
                  end
                end
              end

              describe '::subnet' do
                it 'should retuen a Subnet resource' do
                  vpc = 'vpc'
                  cidr = 'cidr'
                  availability_zone = 'availability_zone'
                  expect(
                    EC2.subnet(
                      vpc: vpc,
                      cidr: cidr,
                      availability_zone: availability_zone
                    )
                  ).to eql(
                    Type: 'AWS::EC2::Subnet',
                    Properties: {
                      VpcId: { Ref: vpc },
                      CidrBlock: cidr,
                      AvailabilityZone: availability_zone
                    }
                  )
                end
              end

              describe '::subnet_route_table_association' do
                it 'should return a SubnetRouteTableAssociation resource' do
                  route_table = 'route_table'
                  subnet = 'subnet'
                  expect(
                    EC2.subnet_route_table_association(
                      route_table: route_table,
                      subnet: subnet
                    )
                  ).to eql(
                    Type: 'AWS::EC2::SubnetRouteTableAssociation',
                    Properties: {
                      RouteTableId: { Ref: route_table },
                      SubnetId: { Ref: subnet }
                    }
                  )
                end
              end

              describe '::security_group' do
                it 'should return a SecurityGroup resource' do
                  group_description = 'group_description'
                  vpc = 'vpc'
                  cidr = 'cidr'
                  protocol = 'protocol'
                  from_port = 'from_port'
                  to_port = 'to_port'
                  expect(
                    EC2.security_group(
                      group_description: group_description,
                      vpc: vpc,
                      egress: [{
                        cidr: cidr,
                        protocol: protocol,
                        from_port: from_port,
                        to_port: to_port
                      }],
                      ingress: [{
                        cidr: cidr,
                        protocol: protocol,
                        from_port: from_port,
                        to_port: to_port
                      }]
                    )
                  ).to eql(
                    Type: 'AWS::EC2::SecurityGroup',
                    Properties: {
                      GroupDescription: group_description,
                      VpcId: { Ref: vpc },
                      SecurityGroupEgress: [{
                        CidrIp: cidr,
                        IpProtocol: protocol,
                        FromPort: from_port,
                        ToPort: to_port
                      }],
                      SecurityGroupIngress: [{
                        CidrIp: cidr,
                        IpProtocol: protocol,
                        FromPort: from_port,
                        ToPort: to_port
                      }]
                    }
                  )
                end
              end

              describe '::security_group_egress' do
                it 'should return a SecurityGroupEgress resource' do
                  security_group = 'security_group'
                  cidr = 'cidr'
                  protocol = 'protocol'
                  from_port = 'from_port'
                  to_port = 'to_port'
                  expect(
                    EC2.security_group_egress(
                      security_group: security_group,
                      cidr: cidr,
                      protocol: protocol,
                      from_port: from_port,
                      to_port: to_port
                    )
                  ).to eql(
                    Type: 'AWS::EC2::SecurityGroupEgress',
                    Properties: {
                      GroupId: { Ref: security_group },
                      CidrIp: cidr,
                      IpProtocol: protocol,
                      FromPort: from_port,
                      ToPort: to_port
                    }
                  )
                end
              end

              describe '::security_group_ingress' do
                it 'should return a SecurityGroupIngress resource' do
                  security_group = 'security_group'
                  cidr = 'cidr'
                  protocol = 'protocol'
                  from_port = 'from_port'
                  to_port = 'to_port'
                  expect(
                    EC2.security_group_ingress(
                      security_group: security_group,
                      cidr: cidr,
                      protocol: protocol,
                      from_port: from_port,
                      to_port: to_port
                    )
                  ).to eql(
                    Type: 'AWS::EC2::SecurityGroupIngress',
                    Properties: {
                      GroupId: { Ref: security_group },
                      CidrIp: cidr,
                      IpProtocol: protocol,
                      FromPort: from_port,
                      ToPort: to_port
                    }
                  )
                end
              end
            end
          end
          # rubocop:enable Metrics/ModuleLength
        end
      end
    end
  end
end
