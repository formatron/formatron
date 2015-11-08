require 'spec_helper'
require 'formatron/cloud_formation/template'

class Formatron
  # namespacing for tests
  # rubocop:disable Metrics/ModuleLength
  module CloudFormation
    describe Template do
      before :each do
        @route53 = class_double(
          'Formatron' \
          '::CloudFormation::Template::Resources::Route53'
        ).as_stubbed_const
        @ec2 = class_double(
          'Formatron' \
          '::CloudFormation::Template::Resources::EC2'
        ).as_stubbed_const
        @iam = class_double(
          'Formatron' \
          '::CloudFormation::Template::Resources::IAM'
        ).as_stubbed_const
        @cloud_formation = class_double(
          'Formatron' \
          '::CloudFormation::Template::Resources::CloudFormation'
        ).as_stubbed_const
        @files = class_double(
          'Formatron' \
          '::CloudFormation::Files'
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

      describe '::add_user' do
        it 'should add the IAM user and access key' do
          template = {}
          user = 'user'
          access_key = 'access_key'
          prefix = 'prefix'
          statements = 'statements'
          expect(@iam).to receive(:user).once.with(
            policy_name: "#{prefix}User",
            statements: statements
          ) { user }
          expect(@iam).to receive(:access_key).once.with(
            user_name: { Ref: "#{prefix}User" }
          ) { access_key }
          Template.add_user(
            template: template,
            prefix: prefix,
            statements: statements
          )
          expect(template).to eql(
            Resources: {
              "#{prefix}User" => user,
              "#{prefix}AccessKey" => access_key
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
        before :each do
          @vpc = instance_double(
            'Formatron::Formatronfile::Bootstrap::VPC'
          )
        end

        it 'should add the VPC resources to the template' do
          cidr = 'cidr'
          subnets = {
            subnet1: 'subnet1',
            subnet2: 'subnet2',
            subnet3: 'subnet3'
          }
          allow(@vpc).to receive(:cidr) { cidr }
          allow(@vpc).to receive(:subnets) { subnets }
          allow(Template).to receive(
            :add_subnet
          ) do |template:, name:, subnet:, vpc:|
            template["#{name}Subnet"] = {
              subnet: subnet,
              vpc: vpc
            }
          end
          template = {}
          expect(@ec2).to receive(:vpc).once.with(cidr: cidr) { @vpc }
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
            vpc: @vpc
          )
          expect(template).to eql(
            'subnet1Subnet' => {
              subnet: subnets[:subnet1],
              vpc: @vpc
            },
            'subnet2Subnet' => {
              subnet: subnets[:subnet2],
              vpc: @vpc
            },
            'subnet3Subnet' => {
              subnet: subnets[:subnet3],
              vpc: @vpc
            },
            Resources: {
              'vpc' => @vpc,
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
          @vpc_cidr = 'vpc_cidr'
          @vpc = instance_double(
            'Formatron::Formatronfile' \
            '::Bootstrap::VPC'
          )
          allow(@vpc).to receive(:cidr) { @vpc_cidr }
          @subnet = instance_double(
            'Formatron::Formatronfile' \
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
              availability_zone: @availability_zone,
              map_public_ip_on_launch: false
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
              subnet: @subnet,
              vpc: @vpc
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
              'Formatron::Formatronfile::Bootstrap' \
              '::VPC::Subnet::ACL'
            )
            allow(@subnet).to receive(:public?) { true }
            allow(@subnet).to receive(:acl) { @acl }
          end

          context 'without any ACL source IP rules' do
            before :each do
              allow(@acl).to receive(:source_cidrs) { [] }
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
                availability_zone: @availability_zone,
                map_public_ip_on_launch: true
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
                subnet: @subnet,
                vpc: @vpc
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
              @source_cidrs = [
                '1.1.1.1',
                '2.2.2.2'
              ]
              allow(@acl).to receive(:source_cidrs) { @source_cidrs }
            end

            it 'should add the subnet resources to the template' do
              template = {}
              subnet = 'subnet'
              subnet_route_table_association =
                'subnet_route_table_association'
              vpc = 'vpc'
              network_acl = 'network_acl'
              network_acl_entry_vpc_inbound =
                'network_acl_entry_vpc_inbound'
              network_acl_entry_external_inbound_tcp =
                'network_acl_entry_external_inbound_tcp'
              network_acl_entry_external_inbound_udp =
                'network_acl_entry_external_inbound_udp'
              network_acl_entry_outbound =
                'network_acl_entry_outbound'
              network_acl_entry_external_inbound_0 =
                'network_acl_entry_external_inbound_0'
              network_acl_entry_external_inbound_1 =
                'network_acl_entry_external_inbound_1'
              subnet_network_acl_association =
                'subnet_network_acl_association'
              expect(@ec2).to receive(:subnet).once.with(
                vpc: vpc,
                cidr: @cidr,
                availability_zone: @availability_zone,
                map_public_ip_on_launch: true
              ) { subnet }
              expect(@ec2).to receive(
                :subnet_route_table_association
              ).once.with(
                route_table: 'publicRouteTable',
                subnet: "#{@name}Subnet"
              ) { subnet_route_table_association }
              expect(@ec2).to receive(:network_acl).once.with(
                vpc: vpc
              ) { network_acl }
              expect(@ec2).to receive(
                :subnet_network_acl_association
              ).once.with(
                subnet: "#{@name}Subnet",
                network_acl: "#{@name}NetworkAcl"
              ) { subnet_network_acl_association }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: @vpc_cidr,
                egress: false,
                protocol: -1,
                action: 'allow',
                icmp_code: -1,
                icmp_type: -1,
                number: 100
              ) { network_acl_entry_vpc_inbound }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: '0.0.0.0/0',
                egress: false,
                protocol: 6,
                action: 'allow',
                start_port: 1024,
                end_port: 65_535,
                number: 200
              ) { network_acl_entry_external_inbound_tcp }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: '0.0.0.0/0',
                egress: false,
                protocol: 17,
                action: 'allow',
                start_port: 1024,
                end_port: 65_535,
                number: 300
              ) { network_acl_entry_external_inbound_udp }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: '0.0.0.0/0',
                egress: true,
                protocol: -1,
                action: 'allow',
                icmp_code: -1,
                icmp_type: -1,
                number: 400
              ) { network_acl_entry_outbound }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: @source_cidrs[0],
                egress: false,
                protocol: -1,
                action: 'allow',
                icmp_code: -1,
                icmp_type: -1,
                number: 500
              ) { network_acl_entry_external_inbound_0 }
              expect(@ec2).to receive(:network_acl_entry).once.with(
                network_acl: "#{@name}NetworkAcl",
                cidr: @source_cidrs[1],
                egress: false,
                protocol: -1,
                action: 'allow',
                icmp_code: -1,
                icmp_type: -1,
                number: 501
              ) { network_acl_entry_external_inbound_1 }
              Template.add_subnet(
                template: template,
                name: @name,
                subnet: @subnet,
                vpc: @vpc
              )
              expect(template).to eql(
                Resources: {
                  "#{@name}Subnet" => subnet,
                  "#{@name}SubnetRouteTableAssociation" =>
                    subnet_route_table_association,
                  "#{@name}NetworkAcl" => network_acl,
                  "#{@name}NetworkAclEntryVpcInbound" =>
                    network_acl_entry_vpc_inbound,
                  "#{@name}NetworkAclEntryExternalInboundTcp" =>
                    network_acl_entry_external_inbound_tcp,
                  "#{@name}NetworkAclEntryExternalInboundUdp" =>
                    network_acl_entry_external_inbound_udp,
                  "#{@name}NetworkAclEntryOutbound" =>
                    network_acl_entry_outbound,
                  "#{@name}NetworkAclEntryExternalInbound0" =>
                    network_acl_entry_external_inbound_0,
                  "#{@name}NetworkAclEntryExternalInbound1" =>
                    network_acl_entry_external_inbound_1,
                  "#{@name}SubnetNetworkAclAssociation" =>
                    subnet_network_acl_association
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

      describe '::add_instance' do
        before :each do
          @template = {}
          @prefix = 'prefix'
          @script = 'script'
          @additional_files = 'additional_files'
          @script_variables = 'script_variables'
          @ingress_rule = 'ingress_rule'
          @source_dest_check = 'source_dest_check'
          @public_hosted_zone_id = 'public_hosted_zone_id'
          @private_hosted_zone_id = 'private_hosted_zone_id'
          @hosted_zone_name = 'hosted_zone_name'
          @sub_domain = 'sub_domain'
          @bucket = 'bucket'
          @get_key = 'get_key'
          @put_key = 'put_key'
          @kms_key = 'kms_key'
          @cidr = 'cidr'
          @availability_zone = 'availability_zone'
          @subnet_name = 'subnet_name'
          @key_pair = 'key_pair'
          @public = 'public'
          @subnet = instance_double(
            'Formatron::Formatronfile' \
            '::Bootstrap::VPC::Subnet'
          )
          @bootstrap_ec2 = instance_double(
            'Formatron::Formatronfile' \
            '::Bootstrap::EC2'
          )
          @subnets = {
            "#{@subnet_name}" => @subnet
          }
          @bootstrap = instance_double(
            'Formatron::Formatronfile::Bootstrap'
          )
          allow(@bootstrap).to receive(:kms_key) { @kms_key }
          @vpc = instance_double(
            'Formatron::Formatronfile::Bootstrap::VPC'
          )
          allow(@bootstrap).to receive(:vpc) { @vpc }
          allow(@bootstrap).to receive(:ec2) { @bootstrap_ec2 }
          allow(@bootstrap_ec2).to receive(:key_pair) { @key_pair }
          allow(@vpc).to receive(:cidr) { @cidr }
          allow(@vpc).to receive(:subnets) { @subnets }
          @instance = instance_double(
            'Formatron::Formatronfile::Instance'
          )
          allow(@instance).to receive(:subnet) { @subnet_name }
          allow(@instance).to receive(:sub_domain) { @sub_domain }
          allow(@subnet).to receive(
            :availability_zone
          ) { @availability_zone }
        end

        it 'should add the instance resources to the template' do
          role = 'role'
          expect(@iam).to receive(:role).once.with(
            no_args
          ) { role }
          instance_profile = 'instance_profile'
          expect(@iam).to receive(:instance_profile).once.with(
            role: "#{@prefix}Role"
          ) { instance_profile }
          policy = 'policy'
          expect(@iam).to receive(:policy).once.with(
            role: "#{@prefix}Role",
            name: "#{@prefix}Policy",
            statements: [{
              actions: [
                'kms:Decrypt',
                'kms:Encrypt',
                'kms:GenerateDataKey*'
              ],
              resources: {
                'Fn::Join' => [
                  '', [
                    'arn:aws:kms:',
                    { Ref: 'AWS::Region' },
                    ':',
                    { Ref: 'AWS::AccountId' },
                    ":key/#{@kms_key}"
                  ]
                ]
              }
            }, {
              actions: 's3:GetObject',
              resources: ["arn:aws:s3:::#{@bucket}/#{@get_key}"]
            }, {
              actions: 's3:PutObject',
              resources: ["arn:aws:s3:::#{@bucket}/#{@put_key}"]
            }]
          ) { policy }
          security_group = 'security_group'
          expect(@ec2).to receive(:security_group).once.with(
            group_description: "#{@prefix} security group",
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
            }, @ingress_rule]
          ) { security_group }
          hostname_sh = 'hostname_sh'
          expect(@files).to receive(:hostname).once.with(
            sub_domain: @sub_domain,
            hosted_zone_name: @hosted_zone_name
          ) { hostname_sh }
          instance = 'instance'
          expect(@ec2).to receive(:instance).once.with(
            script_variables: @script_variables,
            scripts: [
              hostname_sh,
              @script
            ],
            files: @additional_files,
            instance_profile: "#{@prefix}InstanceProfile",
            availability_zone: @availability_zone,
            instance_type: 't2.micro',
            key_name: @key_pair,
            subnet: { Ref: "#{@subnet_name}Subnet" },
            name: "#{@sub_domain}.#{@hosted_zone_name}",
            wait_condition_handle: "#{@prefix}WaitConditionHandle",
            security_group: "#{@prefix}SecurityGroup",
            logical_id: "#{@prefix}Instance",
            source_dest_check: @source_dest_check
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
            wait_condition_handle: "#{@prefix}WaitConditionHandle",
            instance: "#{@prefix}Instance"
          ) { wait_condition }
          expect(@route53).to receive(
            :add_record_sets
          ).once.with(
            template: @template,
            subnet: @subnet,
            private_hosted_zone_id: @private_hosted_zone_id,
            public_hosted_zone_id: @public_hosted_zone_id,
            hosted_zone_name: @hosted_zone_name,
            prefix: @prefix,
            sub_domain: @sub_domain
          # rubocop:disable Metrics/LineLength
          # rubocop:disable Metrics/ParameterLists
          ) do |template:, subnet:, private_hosted_zone_id:, public_hosted_zone_id:, hosted_zone_name:, prefix:, sub_domain:|
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/LineLength
            template[:recordsets] = {
              prefix: prefix,
              subnet: subnet,
              public_hosted_zone_id: public_hosted_zone_id,
              private_hosted_zone_id: private_hosted_zone_id,
              hosted_zone_name: hosted_zone_name,
              sub_domain: sub_domain
            }
          end
          Template.add_instance(
            template: @template,
            prefix: @prefix,
            public_hosted_zone_id: @public_hosted_zone_id,
            private_hosted_zone_id: @private_hosted_zone_id,
            hosted_zone_name: @hosted_zone_name,
            bootstrap: @bootstrap,
            bucket: @bucket,
            s3_keys: {
              put: [@put_key],
              get: [@get_key]
            },
            instance: @instance,
            script_variables: @script_variables,
            scripts: [@script],
            files: @additional_files,
            ingress_rules: [@ingress_rule],
            source_dest_check: @source_dest_check
          )
          expect(@template).to eql(
            recordsets: {
              prefix: @prefix,
              subnet: @subnet,
              public_hosted_zone_id: @public_hosted_zone_id,
              private_hosted_zone_id: @private_hosted_zone_id,
              hosted_zone_name: @hosted_zone_name,
              sub_domain: @sub_domain
            },
            Resources: {
              "#{@prefix}Role" => role,
              "#{@prefix}InstanceProfile" => instance_profile,
              "#{@prefix}Policy" => policy,
              "#{@prefix}SecurityGroup" => security_group,
              "#{@prefix}Instance" => instance,
              "#{@prefix}WaitConditionHandle" => wait_condition_handle,
              "#{@prefix}WaitCondition" => wait_condition
            }
          )
        end
      end

      describe '::add_nat' do
        it 'should add the NAT resources to the template' do
          template = 'template'
          bucket = 'bucket'
          config_key = 'config_key'
          hosted_zone_id = 'hosted_zone_id'
          hosted_zone_name = 'hosted_zone_name'
          cidr = 'cidr'
          nat_sh = 'nat_sh'
          bootstrap = instance_double(
            'Formatron::Formatronfile::Bootstrap'
          )
          nat = instance_double(
            'Formatron::Formatronfile::Instance'
          )
          vpc = instance_double(
            'Formatron::Formatronfile::Bootstrap::VPC'
          )
          expect(bootstrap).to receive(:nat).once.with(
            no_args
          ) { nat }
          expect(bootstrap).to receive(:vpc).once.with(
            no_args
          ) { vpc }
          expect(vpc).to receive(:cidr).once.with(
            no_args
          ) { cidr }
          expect(@files).to receive(:nat).once.with(
            cidr: cidr
          ) { nat_sh }
          expect(Template).to receive(:add_instance).once.with(
            template: template,
            prefix: 'nat',
            bucket: bucket,
            s3_keys: {
              get: [config_key]
            },
            instance: nat,
            bootstrap: bootstrap,
            scripts: [nat_sh],
            ingress_rules: [],
            public_hosted_zone_id: hosted_zone_id,
            private_hosted_zone_id: { Ref: 'privateHostedZone' },
            hosted_zone_name: hosted_zone_name,
            source_dest_check: false
          )
          Template.add_nat(
            template: template,
            bucket: bucket,
            config_key: config_key,
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap
          )
        end
      end

      describe '::add_bastion' do
        it 'should add the Bastion resources to the template' do
          template = 'template'
          bucket = 'bucket'
          config_key = 'config_key'
          hosted_zone_id = 'hosted_zone_id'
          hosted_zone_name = 'hosted_zone_name'
          bootstrap = instance_double(
            'Formatron::Formatronfile::Bootstrap'
          )
          bastion = instance_double(
            'Formatron::Formatronfile::Instance'
          )
          expect(bootstrap).to receive(:bastion).once.with(
            no_args
          ) { bastion }
          expect(Template).to receive(:add_instance).once.with(
            template: template,
            prefix: 'bastion',
            bucket: bucket,
            s3_keys: {
              get: [config_key]
            },
            instance: bastion,
            bootstrap: bootstrap,
            ingress_rules: [{
              cidr: '0.0.0.0/0',
              protocol: 'tcp',
              from_port: '22',
              to_port: '22'
            }],
            public_hosted_zone_id: hosted_zone_id,
            private_hosted_zone_id: { Ref: 'privateHostedZone' },
            hosted_zone_name: hosted_zone_name,
            source_dest_check: true
          )
          Template.add_bastion(
            template: template,
            bucket: bucket,
            config_key: config_key,
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap
          )
        end
      end

      describe '::add_chef_server' do
        it 'should add the Chef Server resources to the template' do
          template = 'template'
          bucket = 'bucket'
          config_key = 'config_key'
          hosted_zone_id = 'hosted_zone_id'
          hosted_zone_name = 'hosted_zone_name'
          chef_server_sh = 'chef_server_sh'
          username = 'username'
          first_name = 'first_name'
          last_name = 'last_name'
          email = 'email'
          password = 'password'
          organization_short_name = 'organization_short_name'
          organization_full_name = 'organization_full_name'
          kms_key = 'kms_key'
          version = 'version'
          cookbooks_bucket = 'cookbooks_bucket'
          user_pem_key = 'user_pem_key'
          organization_pem_key = 'organization_pem_key'
          ssl_cert_key = 'ssl_cert_key'
          ssl_key_key = 'ssl_key_key'
          bootstrap = instance_double(
            'Formatron::Formatronfile::Bootstrap'
          )
          chef_server = instance_double(
            'Formatron::Formatronfile' \
            '::Bootstrap::ChefServer'
          )
          organization = instance_double(
            'Formatron::Formatronfile' \
            '::Bootstrap::ChefServer::Organization'
          )
          expect(chef_server).to receive(:username) { username }
          expect(chef_server).to receive(:first_name) { first_name }
          expect(chef_server).to receive(:last_name) { last_name }
          expect(chef_server).to receive(:email) { email }
          expect(chef_server).to receive(:password) { password }
          expect(chef_server).to receive(:organization) { organization }
          expect(organization).to receive(
            :short_name
          ) { organization_short_name }
          expect(organization).to receive(
            :full_name
          ) { organization_full_name }
          expect(chef_server).to receive(:version) { version }
          expect(chef_server).to receive(
            :cookbooks_bucket
          ) { cookbooks_bucket }
          expect(bootstrap).to receive(:chef_server) { chef_server }
          expect(bootstrap).to receive(:kms_key) { kms_key }
          expect(@files).to receive(:chef_server).once.with(
            username: username,
            first_name: first_name,
            last_name: last_name,
            email: email,
            password: password,
            organization_short_name: organization_short_name,
            organization_full_name: organization_full_name,
            bucket: bucket,
            user_pem_key: user_pem_key,
            organization_pem_key: organization_pem_key,
            kms_key: kms_key,
            chef_server_version: version,
            ssl_cert_key: ssl_cert_key,
            ssl_key_key: ssl_key_key,
            cookbooks_bucket: cookbooks_bucket
          ) { chef_server_sh }
          expect(Template).to receive(:add_instance).once.with(
            template: template,
            prefix: 'chefServer',
            bucket: bucket,
            s3_keys: {
              get: [
                config_key,
                ssl_cert_key,
                ssl_key_key
              ],
              put: [
                user_pem_key,
                organization_pem_key
              ]
            },
            instance: chef_server,
            bootstrap: bootstrap,
            script_variables: {
              'REGION' => { Ref: 'AWS::Region' },
              'ACCESS_KEY_ID' => { Ref: 'chefServerAccessKey' },
              'SECRET_ACCESS_KEY' => {
                'Fn::GetAtt' => %w(
                  chefServerAccessKey
                  SecretAccessKey
                )
              }
            },
            scripts: [chef_server_sh],
            ingress_rules: [{
              cidr: '0.0.0.0/0',
              protocol: 'tcp',
              from_port: '80',
              to_port: '80'
            }, {
              cidr: '0.0.0.0/0',
              protocol: 'tcp',
              from_port: '443',
              to_port: '443'
            }],
            public_hosted_zone_id: hosted_zone_id,
            private_hosted_zone_id: { Ref: 'privateHostedZone' },
            hosted_zone_name: hosted_zone_name,
            source_dest_check: true,
            instance_type: 't2.medium'
          )
          expect(Template).to receive(:add_user).once.with(
            template: template,
            prefix: 'chefServer',
            statements: [{
              actions: ['s3:PutObject', 's3:GetObject', 's3:DeleteObject'],
              resources: "arn:aws:s3:::#{cookbooks_bucket}/*"
            }, {
              actions: ['s3:ListBucket'],
              resources: "arn:aws:s3:::#{cookbooks_bucket}"
            }]
          )
          Template.add_chef_server(
            template: template,
            bucket: bucket,
            config_key: config_key,
            user_pem_key: user_pem_key,
            organization_pem_key: organization_pem_key,
            ssl_cert_key: ssl_cert_key,
            ssl_key_key: ssl_key_key,
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap
          )
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
