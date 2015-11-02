require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation/template'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      # rubocop:disable Metrics/ModuleLength
      module CloudFormation
        describe Template do
          before :each do
            @route53 = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Template::Resources::Route53'
            ).as_stubbed_const
            @ec2 = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Template::Resources::EC2'
            ).as_stubbed_const
            @iam = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Template::Resources::IAM'
            ).as_stubbed_const
            @cloud_formation = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Template::Resources::CloudFormation'
            ).as_stubbed_const
            @scripts = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Scripts'
            ).as_stubbed_const
          end

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

          describe '::add_region_map' do
            it 'should add the region map for AMIs, etc' do
              template = {}
              regions = {
                'region1' => {
                  ami: 'ami1'
                },
                'region2' => {
                  ami: 'ami2'
                }
              }
              stub_const('Formatron::AWS::REGIONS', regions)
              Template.add_region_map template: template
              expect(template).to eql(
                Mappings: {
                  'regionMap' => regions
                }
              )
            end
          end

          describe '::add_private_hosted_zone' do
            it 'should add the Route53 private hosted zone resource' do
              template = {}
              hosted_zone_name = 'hosted_zone_name'
              vpc = 'vpc'
              hosted_zone = 'hosted_zone'
              expect(@route53).to receive(:hosted_zone).once.with(
                name: hosted_zone_name,
                vpc: vpc
              ) { hosted_zone }
              Template.add_private_hosted_zone(
                template: template,
                hosted_zone_name: hosted_zone_name
              )
              expect(template).to eql(
                Resources: {
                  'privateHostedZone' => hosted_zone
                },
                Outputs: {
                  'privateHostedZone' => {
                    Value: { Ref: 'privateHostedZone' }
                  }
                }
              )
            end
          end

          describe '::add_vpc' do
            it 'should add the VPC resources to the template' do
              cidr = 'cidr'
              subnets = {
                subnet1: 'subnet1',
                subnet2: 'subnet2',
                subnet3: 'subnet3'
              }
              vpc = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::VPC'
              )
              allow(vpc).to receive(:cidr) { cidr }
              allow(vpc).to receive(:subnets) { subnets }
              allow(Template).to receive(
                :add_subnet
              ) do |template:, name:, subnet:|
                template["#{name}Subnet"] = subnet
              end
              template = {}
              expect(@ec2).to receive(:vpc).once.with(cidr: cidr) { vpc }
              internet_gateway = 'internet_gateway'
              expect(@ec2).to receive(
                :internet_gateway
              ).once.with(no_args) { internet_gateway }
              vpc_gateway_attachment = 'vpc_gateway_attachment'
              expect(@ec2).to receive(
                :vpc_gateway_attachment
              ).once.with(
                vpc: 'vpc',
                gateway: 'internetGateway'
              ) { vpc_gateway_attachment }
              route_table = 'route_table'
              expect(@ec2).to receive(
                :route_table
              ).twice.with(vpc: 'vpc') { route_table }
              public_route = 'public_route'
              expect(@ec2).to receive(
                :route
              ).once.with(
                route_table: 'publicRouteTable',
                vpc_gateway_attachment: 'vpcGatewayAttachment',
                internet_gateway: 'internetGateway'
              ) { public_route }
              private_route = 'private_route'
              expect(@ec2).to receive(
                :route
              ).once.with(
                route_table: 'privateRouteTable',
                instance: 'natInstance'
              ) { private_route }
              Template.add_vpc(
                template: template,
                vpc: vpc
              )
              expect(template).to eql(
                'subnet1Subnet' => subnets[:subnet1],
                'subnet2Subnet' => subnets[:subnet2],
                'subnet3Subnet' => subnets[:subnet3],
                Resources: {
                  'vpc' => vpc,
                  'internetGateway' => internet_gateway,
                  'vpcGatewayAttachment' => vpc_gateway_attachment,
                  'publicRouteTable' => route_table,
                  'publicRoute' => public_route,
                  'privateRouteTable' => route_table,
                  'privateRoute' => private_route
                },
                Outputs: {
                  'vpc' => {
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
                subnet = 'subnet'
                subnet_route_table_association =
                  'subnet_route_table_association'
                vpc = 'vpc'
                expect(@ec2).to receive(:subnet).once.with(
                  vpc: vpc,
                  cidr: @cidr,
                  availability_zone: @availability_zone
                ) { subnet }
                expect(@ec2).to receive(
                  :subnet_route_table_association
                ).once.with(
                  route_table: 'privateRouteTable',
                  subnet: "#{@name}Subnet"
                ) { subnet_route_table_association }
                Template.add_subnet(
                  template: template,
                  name: @name,
                  subnet: @subnet
                )
                expect(template).to eql(
                  Resources: {
                    "#{@name}Subnet" => subnet,
                    "#{@name}SubnetRouteTableAssociation" =>
                      subnet_route_table_association
                  },
                  Outputs: {
                    "#{@name}Subnet" => {
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
                  subnet = 'subnet'
                  subnet_route_table_association =
                    'subnet_route_table_association'
                  vpc = 'vpc'
                  expect(@ec2).to receive(:subnet).once.with(
                    vpc: vpc,
                    cidr: @cidr,
                    availability_zone: @availability_zone
                  ) { subnet }
                  expect(@ec2).to receive(
                    :subnet_route_table_association
                  ).once.with(
                    route_table: 'publicRouteTable',
                    subnet: "#{@name}Subnet"
                  ) { subnet_route_table_association }
                  Template.add_subnet(
                    template: template,
                    name: @name,
                    subnet: @subnet
                  )
                  expect(template).to eql(
                    Resources: {
                      "#{@name}Subnet" => subnet,
                      "#{@name}SubnetRouteTableAssociation" =>
                        subnet_route_table_association
                    },
                    Outputs: {
                      "#{@name}Subnet" => {
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
                  subnet = 'subnet'
                  subnet_route_table_association =
                    'subnet_route_table_association'
                  vpc = 'vpc'
                  expect(@ec2).to receive(:subnet).once.with(
                    vpc: vpc,
                    cidr: @cidr,
                    availability_zone: @availability_zone
                  ) { subnet }
                  expect(@ec2).to receive(
                    :subnet_route_table_association
                  ).once.with(
                    route_table: 'publicRouteTable',
                    subnet: "#{@name}Subnet"
                  ) { subnet_route_table_association }
                  Template.add_subnet(
                    template: template,
                    name: @name,
                    subnet: @subnet
                  )
                  expect(template).to eql(
                    Resources: {
                      "#{@name}Subnet" => subnet,
                      "#{@name}SubnetRouteTableAssociation" =>
                        subnet_route_table_association
                    },
                    Outputs: {
                      "#{@name}Subnet" => {
                        Value: { Ref: "#{@name}Subnet" }
                      }
                    }
                  )
                end
              end
            end
          end

          describe '::add_nat' do
            before :each do
              @hosted_zone_id = 'hosted_zone_id'
              @hosted_zone_name = 'hosted_zone_name'
              @sub_domain = 'sub_domain'
              @bucket = 'bucket'
              @config_key = 'config_key'
              @kms_key = 'kms_key'
              @cidr = 'cidr'
              @availability_zone = 'availability_zone'
              @subnet_name = 'subnet_name'
              @key_pair = 'key_pair'
              @subnet = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet'
              )
              @bootstrap_ec2 = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::EC2'
              )
              @subnets = {
                "#{@subnet_name}" => @subnet
              }
              @bootstrap = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap'
              )
              allow(@bootstrap).to receive(:kms_key) { @kms_key }
              @vpc = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::VPC'
              )
              allow(@bootstrap).to receive(:vpc) { @vpc }
              allow(@bootstrap).to receive(:ec2) { @bootstrap_ec2 }
              allow(@bootstrap_ec2).to receive(:key_pair) { @key_pair }
              allow(@vpc).to receive(:cidr) { @cidr }
              allow(@vpc).to receive(:subnets) { @subnets }
              @nat = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::NAT'
              )
              allow(@bootstrap).to receive(:nat) { @nat }
              allow(@nat).to receive(:subnet) { @subnet_name }
              allow(@nat).to receive(:sub_domain) { @sub_domain }
              allow(@subnet).to receive(:public?) { true }
              allow(@subnet).to receive(
                :availability_zone
              ) { @availability_zone }
            end

            it 'should add the NAT resources to the template' do
              template = {}
              role = 'role'
              expect(@iam).to receive(:role).once.with(
                no_args
              ) { role }
              instance_profile = 'instance_profile'
              expect(@iam).to receive(:instance_profile).once.with(
                role: 'natRole'
              ) { instance_profile }
              policy = 'policy'
              expect(@iam).to receive(:policy).once.with(
                role: 'natRole',
                name: 'natPolicy',
                statements: [{
                  actions: 's3:GetObject',
                  resources: "arn:aws:s3:::#{@bucket}>/#{@config_key}"
                }, {
                  actions: 'kms:Decrypt',
                  resources: "arn:aws:kms:::key/#{@kms_key}"
                }]
              ) { policy }
              security_group = 'security_group'
              expect(@ec2).to receive(:security_group).once.with(
                group_description: 'NAT security group',
                vpc: 'vpc',
                egress: [{
                  cidr: '0.0.0.0/0',
                  protocol: 'tcp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'udp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'icmp',
                  from_port: '-1',
                  to_port: '-1'
                }],
                ingress: [{
                  cidr: @cidr,
                  protocol: 'tcp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: @cidr,
                  protocol: 'udp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: @cidr,
                  protocol: 'icmp',
                  from_port: '-1',
                  to_port: '-1'
                }]
              ) { security_group }
              hostname_sh = 'hostname_sh'
              expect(@scripts).to receive(:hostname).once.with(
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name
              ) { hostname_sh }
              nat_sh = 'nat_sh'
              expect(@scripts).to receive(:nat).once.with(
                cidr: @cidr
              ) { nat_sh }
              instance = 'instance'
              expect(@ec2).to receive(:instance).once.with(
                scripts: [
                  hostname_sh,
                  nat_sh
                ],
                instance_profile: 'natInstanceProfile',
                availability_zone: @availability_zone,
                instance_type: 't2.micro',
                key_name: @key_pair,
                subnet: { Ref: "#{@subnet_name}Subnet" },
                associate_public_ip_address: true,
                name: 'nat',
                wait_condition_handle: 'natWaitConditionHandle',
                security_group: 'natSecurityGroup',
                logical_id: 'natInstance',
                source_dest_check: false
              ) { instance }
              wait_condition_handle = 'wait_condition_handle'
              expect(@cloud_formation).to receive(
                :wait_condition_handle
              ).once.with(
                no_args
              ) { wait_condition_handle }
              wait_condition = 'wait_condition'
              expect(@cloud_formation).to receive(
                :wait_condition
              ).once.with(
                wait_condition_handle: 'natWaitConditionHandle',
                instance: 'natInstance'
              ) { wait_condition }
              public_record_set = 'public_record_set'
              expect(@route53).to receive(:record_set).once.with(
                hosted_zone_id: @hosted_zone_id,
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name,
                instance: 'natInstance',
                attribute: 'PublicIp'
              ) { public_record_set }
              private_record_set = 'private_record_set'
              expect(@route53).to receive(:record_set).once.with(
                hosted_zone_id: { Ref: 'privateHostedZone' },
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name,
                instance: 'natInstance',
                attribute: 'PrivateIp'
              ) { private_record_set }
              Template.add_nat(
                template: template,
                hosted_zone_id: @hosted_zone_id,
                hosted_zone_name: @hosted_zone_name,
                bootstrap: @bootstrap,
                bucket: @bucket,
                config_key: @config_key
              )
              expect(template).to eql(
                Resources: {
                  'natRole' => role,
                  'natInstanceProfile' => instance_profile,
                  'natPolicy' => policy,
                  'natSecurityGroup' => security_group,
                  'natInstance' => instance,
                  'natWaitConditionHandle' => wait_condition_handle,
                  'natWaitCondition' => wait_condition,
                  'natPublicRecordSet' => public_record_set,
                  'natPrivateRecordSet' => private_record_set
                }
              )
            end
          end

          describe '::add_bastion' do
            before :each do
              @hosted_zone_id = 'hosted_zone_id'
              @hosted_zone_name = 'hosted_zone_name'
              @sub_domain = 'sub_domain'
              @bucket = 'bucket'
              @config_key = 'config_key'
              @kms_key = 'kms_key'
              @cidr = 'cidr'
              @availability_zone = 'availability_zone'
              @subnet_name = 'subnet_name'
              @key_pair = 'key_pair'
              @subnet = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet'
              )
              @bootstrap_ec2 = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::EC2'
              )
              @subnets = {
                "#{@subnet_name}" => @subnet
              }
              @bootstrap = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap'
              )
              allow(@bootstrap).to receive(:kms_key) { @kms_key }
              @vpc = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::VPC'
              )
              allow(@bootstrap).to receive(:vpc) { @vpc }
              allow(@bootstrap).to receive(:ec2) { @bootstrap_ec2 }
              allow(@bootstrap_ec2).to receive(:key_pair) { @key_pair }
              allow(@vpc).to receive(:cidr) { @cidr }
              allow(@vpc).to receive(:subnets) { @subnets }
              @bastion = instance_double(
                'Formatron::Configuration::Formatronfile::Bootstrap::Bastion'
              )
              allow(@bootstrap).to receive(:bastion) { @bastion }
              allow(@bastion).to receive(:subnet) { @subnet_name }
              allow(@bastion).to receive(:sub_domain) { @sub_domain }
              allow(@subnet).to receive(:public?) { true }
              allow(@subnet).to receive(
                :availability_zone
              ) { @availability_zone }
            end

            it 'should add the Bastion resources to the template' do
              template = {}
              role = 'role'
              expect(@iam).to receive(:role).once.with(
                no_args
              ) { role }
              instance_profile = 'instance_profile'
              expect(@iam).to receive(:instance_profile).once.with(
                role: 'bastionRole'
              ) { instance_profile }
              policy = 'policy'
              expect(@iam).to receive(:policy).once.with(
                role: 'bastionRole',
                name: 'bastionPolicy',
                statements: [{
                  actions: 's3:GetObject',
                  resources: "arn:aws:s3:::#{@bucket}>/#{@config_key}"
                }, {
                  actions: 'kms:Decrypt',
                  resources: "arn:aws:kms:::key/#{@kms_key}"
                }]
              ) { policy }
              security_group = 'security_group'
              expect(@ec2).to receive(:security_group).once.with(
                group_description: 'Bastion security group',
                vpc: 'vpc',
                egress: [{
                  cidr: '0.0.0.0/0',
                  protocol: 'tcp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'udp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'icmp',
                  from_port: '-1',
                  to_port: '-1'
                }],
                ingress: [{
                  cidr: '0.0.0.0/0',
                  protocol: 'tcp',
                  from_port: '22',
                  to_port: '22'
                }, {
                  cidr: @cidr,
                  protocol: 'tcp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: @cidr,
                  protocol: 'udp',
                  from_port: '0',
                  to_port: '65535'
                }, {
                  cidr: @cidr,
                  protocol: 'icmp',
                  from_port: '-1',
                  to_port: '-1'
                }]
              ) { security_group }
              hostname_sh = 'hostname_sh'
              expect(@scripts).to receive(:hostname).once.with(
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name
              ) { hostname_sh }
              instance = 'instance'
              expect(@ec2).to receive(:instance).once.with(
                scripts: [
                  hostname_sh
                ],
                instance_profile: 'bastionInstanceProfile',
                availability_zone: @availability_zone,
                instance_type: 't2.micro',
                key_name: @key_pair,
                subnet: { Ref: "#{@subnet_name}Subnet" },
                associate_public_ip_address: true,
                name: 'bastion',
                wait_condition_handle: 'bastionWaitConditionHandle',
                security_group: 'bastionSecurityGroup',
                logical_id: 'bastionInstance',
                source_dest_check: false
              ) { instance }
              wait_condition_handle = 'wait_condition_handle'
              expect(@cloud_formation).to receive(
                :wait_condition_handle
              ).once.with(
                no_args
              ) { wait_condition_handle }
              wait_condition = 'wait_condition'
              expect(@cloud_formation).to receive(
                :wait_condition
              ).once.with(
                wait_condition_handle: 'bastionWaitConditionHandle',
                instance: 'bastionInstance'
              ) { wait_condition }
              public_record_set = 'public_record_set'
              expect(@route53).to receive(:record_set).once.with(
                hosted_zone_id: @hosted_zone_id,
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name,
                instance: 'bastionInstance',
                attribute: 'PublicIp'
              ) { public_record_set }
              private_record_set = 'private_record_set'
              expect(@route53).to receive(:record_set).once.with(
                hosted_zone_id: { Ref: 'privateHostedZone' },
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name,
                instance: 'bastionInstance',
                attribute: 'PrivateIp'
              ) { private_record_set }
              Template.add_bastion(
                template: template,
                hosted_zone_id: @hosted_zone_id,
                hosted_zone_name: @hosted_zone_name,
                bootstrap: @bootstrap,
                bucket: @bucket,
                config_key: @config_key
              )
              expect(template).to eql(
                Resources: {
                  'bastionRole' => role,
                  'bastionInstanceProfile' => instance_profile,
                  'bastionPolicy' => policy,
                  'bastionSecurityGroup' => security_group,
                  'bastionInstance' => instance,
                  'bastionWaitConditionHandle' => wait_condition_handle,
                  'bastionWaitCondition' => wait_condition,
                  'bastionPublicRecordSet' => public_record_set,
                  'bastionPrivateRecordSet' => private_record_set
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
