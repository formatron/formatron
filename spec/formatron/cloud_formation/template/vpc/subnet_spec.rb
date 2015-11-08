require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet'

class Formatron
  module CloudFormation
    class Template
      # namespacing tests
      class VPC
        describe Subnet do
          include TemplateTest

          before :each do
            @formatronfile_subnet = instance_double(
              'Formatron::Formatronfile::VPC::Subnet'
            )
            @results = {}
            @formatronfile_instances = {}
            {
              nat: 'NAT',
              bastion: 'Bastion',
              chef_server: 'ChefServer',
              instance: 'Instance'
            }.each do |symbol, cls|
              test_instances(
                tag: symbol,
                template_cls: 'Formatron::CloudFormation::Template' \
                              "::VPC::Subnet::#{cls}",
                formatronfile_cls: 'Formatron::Formatronfile' \
                                   "::VPC::Subnet::#{cls}"
              )
              allow(@formatronfile_subnet).to receive(
                symbol
              ) { @formatronfile_instances[symbol] }
            end
            formatronfile_vpc = instance_double 'Formatron::Formatronfile::VPC'
            @vpc_guid = 'vpc_guid'
            allow(formatronfile_vpc).to receive(:guid) { @vpc_guid }
            allow(@formatronfile_subnet).to receive(
              :dsl_parent
            ) { formatronfile_vpc }
            @subnet_guid = 'subnet_guid'
            allow(@formatronfile_subnet).to receive(:guid) { @subnet_guid }
            @subnet_cidr = 'subnet_cidr'
            allow(@formatronfile_subnet).to receive(:cidr) { @subnet_cidr }
            @availability_zone = 'availability_zone'
            allow(@formatronfile_subnet).to receive(
              :availability_zone
            ) { @availability_zone }
            allow(@formatronfile_subnet).to receive(
              :gateway
            ) { nil }
            @subnet = 'subnet'
            @ec2 = class_double(
              'Formatron::CloudFormation::Template::Resources::EC2'
            ).as_stubbed_const
            allow(@ec2).to receive(:subnet).with(
              vpc: "vpc#{@vpc_guid}",
              cidr: @subnet_cidr,
              availability_zone: @availability_zone,
              map_public_ip_on_launch: true
            ) { @subnet }
            @template_subnet = Subnet.new subnet: @formatronfile_subnet
            @logical_id = "subnet#{@subnet_guid}"
          end

          describe '#merge' do
            before :each do
              @resources = {}
              @outputs = {}
              @template_subnet.merge resources: @resources, outputs: @outputs
            end

            it 'should add the NATs, bastions, chef servers and ' \
               'generic instances' do
              expect(@resources).to include @results
              expect(@outputs).to include @results
            end

            it 'should add a subnet to the resources' do
              expect(@resources).to include(
                @logical_id => @subnet
              )
              expect(@outputs).to include(
                @logical_id => {
                  Value: { Ref: @logical_id }
                }
              )
            end

            context 'when there is a gateway specified' do
              before :each do
                gateway = 'gateway'
                allow(@formatronfile_subnet).to receive(
                  :gateway
                ) { gateway }
                allow(@ec2).to receive(:subnet).with(
                  vpc: "vpc#{@vpc_guid}",
                  cidr: @subnet_cidr,
                  availability_zone: @availability_zone,
                  map_public_ip_on_launch: false
                ) { @subnet }
                @resources = {}
                @outputs = {}
                @template_subnet.merge resources: @resources, outputs: @outputs
              end

              it 'should add a subnet that does not map public IPs' do
                expect(@resources).to include(
                  @logical_id => @subnet
                )
              end
            end
          end
        end
      end
    end
  end
end
