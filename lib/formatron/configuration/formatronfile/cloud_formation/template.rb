require_relative 'template/resources/route53'
require_relative 'template/resources/ec2'
require_relative 'template/resources/iam'
require_relative 'template/resources/cloud_formation'
require_relative 'files'
require 'formatron/aws'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation template JSON
        # rubocop:disable Metrics/ModuleLength
        module Template
          REGION_MAP = 'regionMap'
          PRIVATE_HOSTED_ZONE = 'privateHostedZone'
          VPC = 'vpc'
          INTERNET_GATEWAY = 'internetGateway'
          VPC_GATEWAY_ATTACHMENT = 'vpcGatewayAttachment'
          PUBLIC_ROUTE_TABLE = 'publicRouteTable'
          PUBLIC_ROUTE = 'publicRoute'
          PRIVATE_ROUTE_TABLE = 'privateRouteTable'
          PRIVATE_ROUTE = 'privateRoute'
          SUBNET = 'Subnet'
          SUBNET_ROUTE_TABLE_ASSOCIATION = 'SubnetRouteTableAssociation'
          INSTANCE = 'Instance'
          ROLE = 'Role'
          INSTANCE_PROFILE = 'InstanceProfile'
          POLICY = 'Policy'
          SECURITY_GROUP = 'SecurityGroup'
          WAIT_CONDITION_HANDLE = 'WaitConditionHandle'
          WAIT_CONDITION = 'WaitCondition'
          PUBLIC_RECORD_SET = 'PublicRecordSet'
          PRIVATE_RECORD_SET = 'PrivateRecordSet'
          NAT = 'nat'
          BASTION = 'bastion'
          CHEF_SERVER = 'chefServer'

          # rubocop:disable Metrics/MethodLength
          def self._security_group_base_egress_rules
            [{
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
            }]
          end
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          def self._security_group_base_ingress_rules(cidr)
            [{
              cidr: cidr,
              protocol: 'tcp',
              from_port: '0',
              to_port: '65535'
            }, {
              cidr: cidr,
              protocol: 'udp',
              from_port: '0',
              to_port: '65535'
            }, {
              cidr: cidr,
              protocol: 'icmp',
              from_port: '-1',
              to_port: '-1'
            }]
          end
          # rubocop:enable Metrics/MethodLength

          def self.create(description)
            {
              AWSTemplateFormatVersion: '2010-09-09',
              Description: "#{description}"
            }
          end

          def self.add_region_map(template:)
            mappings = mappings template
            mappings[REGION_MAP] = Formatron::AWS::REGIONS
          end

          def self.add_private_hosted_zone(
            template:,
            hosted_zone_name:
          )
            resources = resources template
            outputs = outputs template
            resources[PRIVATE_HOSTED_ZONE] = Resources::Route53.hosted_zone(
              name: hosted_zone_name,
              vpc: VPC
            )
            outputs[PRIVATE_HOSTED_ZONE] = output ref(PRIVATE_HOSTED_ZONE)
          end

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/AbcSize
          def self.add_vpc(template:, vpc:)
            resources = resources template
            outputs = outputs template
            resources[VPC] = Resources::EC2.vpc cidr: vpc.cidr
            resources[INTERNET_GATEWAY] = Resources::EC2.internet_gateway
            resources[VPC_GATEWAY_ATTACHMENT] =
              Resources::EC2.vpc_gateway_attachment(
                gateway: INTERNET_GATEWAY,
                vpc: VPC
              )
            resources[PUBLIC_ROUTE_TABLE] = Resources::EC2.route_table(
              vpc: VPC
            )
            resources[PUBLIC_ROUTE] = Resources::EC2.route(
              vpc_gateway_attachment: VPC_GATEWAY_ATTACHMENT,
              route_table: PUBLIC_ROUTE_TABLE,
              internet_gateway: INTERNET_GATEWAY
            )
            resources[PRIVATE_ROUTE_TABLE] = Resources::EC2.route_table(
              vpc: VPC
            )
            resources[PRIVATE_ROUTE] = Resources::EC2.route(
              route_table: PRIVATE_ROUTE_TABLE,
              instance: "#{NAT}#{INSTANCE}"
            )
            outputs[VPC] = output ref(VPC)
            vpc.subnets.each do |name, subnet|
              add_subnet(
                template: template,
                name: name,
                subnet: subnet
              )
            end
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          def self.add_subnet(template:, name:, subnet:)
            route_table =
              subnet.public? ? PUBLIC_ROUTE_TABLE : PRIVATE_ROUTE_TABLE
            resources = resources template
            outputs = outputs template
            resources["#{name}#{SUBNET}"] = Resources::EC2.subnet(
              vpc: VPC,
              cidr: subnet.cidr,
              availability_zone: subnet.availability_zone
            )
            resources["#{name}#{SUBNET_ROUTE_TABLE_ASSOCIATION}"] =
              Resources::EC2.subnet_route_table_association(
                route_table: route_table,
                subnet: "#{name}#{SUBNET}"
              )
            outputs["#{name}#{SUBNET}"] = output ref("#{name}#{SUBNET}")
          end
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          def self.add_nat(
            template:,
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:
          )
            add_instance(
              template: template,
              prefix: NAT,
              bucket: bucket,
              config_key: config_key,
              instance: bootstrap.nat,
              bootstrap: bootstrap,
              scripts: [Files.nat(cidr: bootstrap.vpc.cidr)],
              files: [],
              ingress_rules: [],
              public_hosted_zone_id: hosted_zone_id,
              private_hosted_zone_id: Template.ref(PRIVATE_HOSTED_ZONE),
              hosted_zone_name: hosted_zone_name,
              source_dest_check: false
            )
          end
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          def self.add_bastion(
            template:,
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:
          )
            add_instance(
              template: template,
              prefix: BASTION,
              bucket: bucket,
              config_key: config_key,
              instance: bootstrap.bastion,
              bootstrap: bootstrap,
              scripts: [],
              files: [],
              ingress_rules: [{
                cidr: '0.0.0.0/0',
                protocol: 'tcp',
                from_port: '22',
                to_port: '22'
              }],
              public_hosted_zone_id: hosted_zone_id,
              private_hosted_zone_id: Template.ref(PRIVATE_HOSTED_ZONE),
              hosted_zone_name: hosted_zone_name,
              source_dest_check: true
            )
          end
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          def self.add_chef_server(
            template:,
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:
          )
            chef_server = bootstrap.chef_server
            add_instance(
              template: template,
              prefix: CHEF_SERVER,
              bucket: bucket,
              config_key: config_key,
              instance: chef_server,
              bootstrap: bootstrap,
              scripts: [Files.chef_server],
              files: [],
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
              private_hosted_zone_id: Template.ref(PRIVATE_HOSTED_ZONE),
              hosted_zone_name: hosted_zone_name,
              source_dest_check: true
            )
          end
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/AbcSize
          # rubocop:disable Metrics/ParameterLists
          # rubocop:disable Metrics/MethodLength
          def self.add_instance(
            template:,
            prefix:,
            bucket:,
            config_key:,
            instance:,
            bootstrap:,
            ingress_rules:,
            scripts:,
            files:,
            public_hosted_zone_id:,
            private_hosted_zone_id:,
            hosted_zone_name:,
            source_dest_check:
          )
            resources = resources template
            resources["#{prefix}#{ROLE}"] = Resources::IAM.role
            resources["#{prefix}#{INSTANCE_PROFILE}"] =
              Resources::IAM.instance_profile(
                role: "#{prefix}#{ROLE}"
              )
            resources["#{prefix}#{POLICY}"] = Resources::IAM.policy(
              role: "#{prefix}#{ROLE}",
              name: "#{prefix}#{POLICY}",
              statements: [{
                actions: 's3:GetObject',
                resources: "arn:aws:s3:::#{bucket}>/#{config_key}"
              }, {
                actions: 'kms:Decrypt',
                resources: "arn:aws:kms:::key/#{bootstrap.kms_key}"
              }]
            )
            resources["#{prefix}#{SECURITY_GROUP}"] =
              Resources::EC2.security_group(
                group_description: "#{prefix} security group",
                vpc: VPC,
                egress: _security_group_base_egress_rules,
                ingress: _security_group_base_ingress_rules(
                  bootstrap.vpc.cidr
                ).concat(ingress_rules)
              )
            resources["#{prefix}#{INSTANCE}"] = Resources::EC2.instance(
              scripts: [
                Files.hostname(
                  sub_domain: instance.sub_domain,
                  hosted_zone_name: hosted_zone_name
                )
              ].concat(scripts),
              files: files,
              instance_profile: "#{prefix}#{INSTANCE_PROFILE}",
              availability_zone: bootstrap.vpc.subnets[
                instance.subnet
              ].availability_zone,
              instance_type: 't2.micro',
              key_name: bootstrap.ec2.key_pair,
              subnet: ref("#{instance.subnet}#{SUBNET}"),
              associate_public_ip_address: bootstrap.vpc.subnets[
                instance.subnet
              ].public?,
              name: "#{instance.sub_domain}.#{hosted_zone_name}",
              wait_condition_handle: "#{prefix}#{WAIT_CONDITION_HANDLE}",
              security_group: "#{prefix}#{SECURITY_GROUP}",
              logical_id: "#{prefix}#{INSTANCE}",
              source_dest_check: source_dest_check
            )
            resources["#{prefix}#{WAIT_CONDITION_HANDLE}"] =
              Resources::CloudFormation.wait_condition_handle
            resources["#{prefix}#{WAIT_CONDITION}"] =
              Resources::CloudFormation.wait_condition(
                instance: "#{prefix}#{INSTANCE}",
                wait_condition_handle: "#{prefix}#{WAIT_CONDITION_HANDLE}"
              )
            Resources::Route53.add_record_sets(
              template: template,
              private_hosted_zone_id: private_hosted_zone_id,
              public_hosted_zone_id: public_hosted_zone_id,
              prefix: prefix,
              sub_domain: instance.sub_domain,
              subnet: bootstrap.vpc.subnets[instance.subnet],
              hosted_zone_name: hosted_zone_name
            )
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          def self.resources(template)
            template[:Resources] ||= {}
          end

          def self.outputs(template)
            template[:Outputs] ||= {}
          end

          def self.mappings(template)
            template[:Mappings] ||= {}
          end

          def self.ref(logical_id)
            {
              Ref: logical_id
            }
          end

          def self.join(*items)
            {
              'Fn::Join' => [
                '', items
              ]
            }
          end

          def self.find_in_map(map, key, property)
            {
              'Fn::FindInMap' => [
                map,
                key,
                property
              ]
            }
          end

          def self.base_64(value)
            {
              'Fn::Base64' => value
            }
          end

          def self.get_attribute(resource, attribute)
            {
              'Fn::GetAtt' => [resource, attribute]
            }
          end

          def self.output(value)
            {
              Value: value
            }
          end

          private_class_method(
            :_security_group_base_egress_rules,
            :_security_group_base_ingress_rules
          )
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
