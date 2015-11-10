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
            @subnet_guid = 'subnet_guid'
            @key_pair = 'key_pair'
            @availability_zone = 'availability_zone'
            @hosted_zone_name = 'hosted_zone_name'
            @vpc_guid = 'vpc_guid'
            @vpc_cidr = 'vpc_cidr'
            @kms_key = 'kms_key'
            @public_hosted_zone_id = 'public_hosted_zone_id'
            @private_hosted_zone_id = 'private_hosted_zone_id'
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
                args: {
                  key_pair: @key_pair,
                  availability_zone: @availability_zone,
                  subnet_guid: @subnet_guid,
                  hosted_zone_name: @hosted_zone_name,
                  vpc_guid: @vpc_guid,
                  vpc_cidr: @vpc_cidr,
                  kms_key: @kms_key,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  public_hosted_zone_id: nil
                },
                template_cls: 'Formatron::CloudFormation::Template' \
                              "::VPC::Subnet::#{cls}",
                formatronfile_cls: 'Formatron::Formatronfile' \
                                   "::VPC::Subnet::#{cls}"
              )
              allow(@formatronfile_subnet).to receive(
                symbol
              ) { @formatronfile_instances[symbol] }
            end
            allow(@formatronfile_subnet).to receive(:guid) { @subnet_guid }
            @subnet_cidr = 'subnet_cidr'
            allow(@formatronfile_subnet).to receive(:cidr) { @subnet_cidr }
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
              acl: formatronfile_acl,
              subnet_guid: @subnet_guid,
              vpc_guid: @vpc_guid,
              vpc_cidr: @vpc_cidr
            ) { template_acl }
            allow(template_acl).to receive(:merge) do |resources:|
              resources[:acl] = @acl
            end
            allow(@formatronfile_subnet).to receive(:acl) { formatronfile_acl }
            @template_subnet = Subnet.new(
              subnet: @formatronfile_subnet,
              vpc_guid: @vpc_guid,
              vpc_cidr: @vpc_cidr,
              key_pair: @key_pair,
              hosted_zone_name: @hosted_zone_name,
              kms_key: @kms_key,
              instances: [],
              public_hosted_zone_id: @public_hosted_zone_id,
              private_hosted_zone_id: @private_hosted_zone_id
            )
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
                    args: {
                      key_pair: @key_pair,
                      availability_zone: @availability_zone,
                      subnet_guid: @subnet_guid,
                      hosted_zone_name: @hosted_zone_name,
                      vpc_guid: @vpc_guid,
                      vpc_cidr: @vpc_cidr,
                      kms_key: @kms_key,
                      private_hosted_zone_id: @private_hosted_zone_id,
                      public_hosted_zone_id: @public_hosted_zone_id
                    },
                    template_cls: 'Formatron::CloudFormation::Template' \
                                  "::VPC::Subnet::#{cls}",
                    formatronfile_cls: 'Formatron::Formatronfile' \
                                       "::VPC::Subnet::#{cls}"
                  )
                  allow(@formatronfile_subnet).to receive(
                    symbol
                  ) { @formatronfile_instances[symbol] }
                end
                gateway = 'gateway'
                gateway_instance = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet::NAT'
                )
                instances = {
                  gateway => gateway_instance
                }
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
                @template_subnet = Subnet.new(
                  subnet: @formatronfile_subnet,
                  vpc_guid: @vpc_guid,
                  vpc_cidr: @vpc_cidr,
                  key_pair: @key_pair,
                  hosted_zone_name: @hosted_zone_name,
                  kms_key: @kms_key,
                  instances: instances,
                  public_hosted_zone_id: @public_hosted_zone_id,
                  private_hosted_zone_id: @private_hosted_zone_id
                )
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
