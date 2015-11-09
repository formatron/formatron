require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet'

class Formatron
  module CloudFormation
    class Template
      # rubocop:disable Metrics/ClassLength
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
            @formatronfile_vpc = instance_double 'Formatron::Formatronfile::VPC'
            @vpc_guid = 'vpc_guid'
            allow(@formatronfile_vpc).to receive(:guid) { @vpc_guid }
            allow(@formatronfile_subnet).to receive(
              :dsl_parent
            ) { @formatronfile_vpc }
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
              'Formatron::CloudFormation::Resources::EC2'
            ).as_stubbed_const
            allow(@ec2).to receive(:subnet).with(
              vpc: "vpc#{@vpc_guid}",
              cidr: @subnet_cidr,
              availability_zone: @availability_zone,
              map_public_ip_on_launch: true
            ) { @subnet }
            @logical_id = "subnet#{@subnet_guid}"
            @subnet_route_table_association_id =
              "subnetRouteTableAssociation#{@subnet_guid}"
            @subnet_route_table_association = 'subnet_route_table_association'
            public_route_table_id = "routeTable#{@vpc_guid}"
            allow(@ec2).to receive(:subnet_route_table_association).with(
              route_table: public_route_table_id,
              subnet: @logical_id
            ) { @subnet_route_table_association }
            @acl = 'acl'
            formatronfile_acl = instance_double 'Formatron::Formatronfile' \
                                                 '::VPC::Subnet::ACL'
            template_acl_class = class_double(
              'Formatron::CloudFormation::Template' \
              '::VPC::Subnet::ACL'
            ).as_stubbed_const
            template_acl = instance_double(
              'Formatron::CloudFormation::Template' \
              '::VPC::Subnet::ACL'
            )
            allow(template_acl_class).to receive(:new).with(
              acl: formatronfile_acl
            ) { template_acl }
            allow(template_acl).to receive(:merge) do |resources:|
              resources[:acl] = @acl
            end
            allow(@formatronfile_subnet).to receive(:acl) { formatronfile_acl }
            @template_subnet = Subnet.new subnet: @formatronfile_subnet
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

            it 'should add a subnet route table association' do
              expect(@resources).to include(
                @subnet_route_table_association_id =>
                  @subnet_route_table_association
              )
            end

            it 'should add an ACL' do
              expect(@resources).to include(
                acl: @acl
              )
            end

            context 'when there is a gateway specified' do
              before :each do
                @resources = {}
                @outputs = {}
                formatronfile = instance_double 'Formatron::Formatronfile'
                allow(@formatronfile_vpc).to receive(
                  :dsl_parent
                ) { formatronfile }
                formatron = instance_double 'Formatron'
                allow(formatronfile).to receive(:dsl_parent) { formatron }
                gateway = 'gateway'
                gateway_instance = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet::NAT'
                )
                allow(formatron).to receive(:instance).with(
                  name: gateway
                ) { gateway_instance }
                gateway_guid = 'gateway_guid'
                allow(gateway_instance).to receive(:guid) { gateway_guid }
                allow(@formatronfile_subnet).to receive(
                  :gateway
                ) { gateway }
                @private_subnet = 'private_subnet'
                allow(@ec2).to receive(:subnet).with(
                  vpc: "vpc#{@vpc_guid}",
                  cidr: @subnet_cidr,
                  availability_zone: @availability_zone,
                  map_public_ip_on_launch: false
                ) { @private_subnet }
                stub_const(
                  'Formatron::CloudFormation::Template::VPC' \
                  '::Subnet::NAT::ROUTE_TABLE_PREFIX',
                  'routeTable'
                )
                private_route_table_id = "routeTable#{gateway_guid}"
                @private_subnet_route_table_association =
                  'private_subnet_route_table_association'
                allow(@ec2).to receive(:subnet_route_table_association).with(
                  route_table: private_route_table_id,
                  subnet: @logical_id
                ) { @private_subnet_route_table_association }
                @template_subnet = Subnet.new subnet: @formatronfile_subnet
                @template_subnet.merge resources: @resources, outputs: @outputs
              end

              it 'should add a subnet that does not map public IPs' do
                expect(@resources).to include(
                  @logical_id => @private_subnet
                )
              end

              it 'should add a subnet route table association ' \
                 'for the gateway' do
                expect(@resources).to include(
                  @subnet_route_table_association_id =>
                    @private_subnet_route_table_association
                )
              end

              it 'should not add an ACL' do
                expect(@resources).to_not include(
                  acl: @acl
                )
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
