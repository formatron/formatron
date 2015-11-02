require_relative 'template/resources/route53'
require_relative 'template/resources/ec2'
require_relative 'template/resources/iam'
require_relative 'template/resources/cloud_formation'
require_relative 'scripts'
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
          NAT_INSTANCE = 'natInstance'
          NAT_ROLE = 'natRole'
          NAT_INSTANCE_PROFILE = 'natInstanceProfile'
          NAT_POLICY = 'natPolicy'
          NAT_SECURITY_GROUP = 'natSecurityGroup'
          NAT_WAIT_CONDITION_HANDLE = 'natWaitConditionHandle'
          NAT_WAIT_CONDITION = 'natWaitCondition'
          NAT_PUBLIC_RECORD_SET = 'natPublicRecordSet'
          NAT_PRIVATE_RECORD_SET = 'natPrivateRecordSet'
          BASTION_INSTANCE = 'bastionInstance'
          BASTION_ROLE = 'bastionRole'
          BASTION_INSTANCE_PROFILE = 'bastionInstanceProfile'
          BASTION_POLICY = 'bastionPolicy'
          BASTION_SECURITY_GROUP = 'bastionSecurityGroup'
          BASTION_WAIT_CONDITION_HANDLE = 'bastionWaitConditionHandle'
          BASTION_WAIT_CONDITION = 'bastionWaitCondition'
          BASTION_PUBLIC_RECORD_SET = 'bastionPublicRecordSet'
          BASTION_PRIVATE_RECORD_SET = 'bastionPrivateRecordSet'

          def self.create(description)
            {
              AWSTemplateFormatVersion: '2010-09-09',
              Description: "#{description}"
            }
          end

          def self.add_region_map(template:)
            mappings = _mappings template
            mappings[REGION_MAP] = Formatron::AWS::REGIONS
          end

          def self.add_private_hosted_zone(
            template:,
            hosted_zone_name:
          )
            resources = _resources template
            outputs = _outputs template
            resources[PRIVATE_HOSTED_ZONE] = Resources::Route53.hosted_zone(
              name: hosted_zone_name,
              vpc: VPC
            )
            outputs[PRIVATE_HOSTED_ZONE] = output ref(PRIVATE_HOSTED_ZONE)
          end

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/AbcSize
          def self.add_vpc(template:, vpc:)
            resources = _resources template
            outputs = _outputs template
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
              instance: NAT_INSTANCE
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
            resources = _resources template
            outputs = _outputs template
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
          # rubocop:disable Metrics/AbcSize
          def self.add_nat(
            template:,
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:
          )
            puts hosted_zone_name
            puts hosted_zone_id
            resources = _resources template
            resources[NAT_ROLE] = Resources::IAM.role
            resources[NAT_INSTANCE_PROFILE] = Resources::IAM.instance_profile(
              role: NAT_ROLE
            )
            resources[NAT_POLICY] = Resources::IAM.policy(
              role: NAT_ROLE,
              name: NAT_POLICY,
              statements: [{
                actions: 's3:GetObject',
                resources: "arn:aws:s3:::#{bucket}>/#{config_key}"
              }, {
                actions: 'kms:Decrypt',
                resources: "arn:aws:kms:::key/#{bootstrap.kms_key}"
              }]
            )
            resources[NAT_SECURITY_GROUP] = Resources::EC2.security_group(
              group_description: 'NAT security group',
              vpc: VPC,
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
                cidr: bootstrap.vpc.cidr,
                protocol: 'tcp',
                from_port: '0',
                to_port: '65535'
              }, {
                cidr: bootstrap.vpc.cidr,
                protocol: 'udp',
                from_port: '0',
                to_port: '65535'
              }, {
                cidr: bootstrap.vpc.cidr,
                protocol: 'icmp',
                from_port: '-1',
                to_port: '-1'
              }]
            )
            resources[NAT_INSTANCE] = Resources::EC2.instance(
              scripts: [
                Scripts.hostname(
                  sub_domain: bootstrap.nat.sub_domain,
                  hosted_zone_name: hosted_zone_name
                ),
                Scripts.nat(
                  cidr: bootstrap.vpc.cidr
                )
              ],
              instance_profile: NAT_INSTANCE_PROFILE,
              availability_zone: bootstrap.vpc.subnets[
                bootstrap.nat.subnet
              ].availability_zone,
              instance_type: 't2.micro',
              key_name: bootstrap.ec2.key_pair,
              subnet: ref("#{bootstrap.nat.subnet}#{SUBNET}"),
              associate_public_ip_address: bootstrap.vpc.subnets[
                bootstrap.nat.subnet
              ].public?,
              name: 'nat',
              wait_condition_handle: NAT_WAIT_CONDITION_HANDLE,
              security_group: NAT_SECURITY_GROUP,
              logical_id: NAT_INSTANCE,
              source_dest_check: false
            )
            resources[NAT_WAIT_CONDITION_HANDLE] =
              Resources::CloudFormation.wait_condition_handle
            resources[NAT_WAIT_CONDITION] =
              Resources::CloudFormation.wait_condition(
                instance: NAT_INSTANCE,
                wait_condition_handle: NAT_WAIT_CONDITION_HANDLE
              )
            resources[NAT_PUBLIC_RECORD_SET] = Resources::Route53.record_set(
              hosted_zone_id: hosted_zone_id,
              sub_domain: bootstrap.nat.sub_domain,
              hosted_zone_name: hosted_zone_name,
              instance: NAT_INSTANCE,
              attribute: 'PublicIp'
            )
            resources[NAT_PRIVATE_RECORD_SET] = Resources::Route53.record_set(
              hosted_zone_id: Template.ref(PRIVATE_HOSTED_ZONE),
              sub_domain: bootstrap.nat.sub_domain,
              hosted_zone_name: hosted_zone_name,
              instance: NAT_INSTANCE,
              attribute: 'PrivateIp'
            )
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          # rubocop:disable Metrics/AbcSize
          def self.add_bastion(
            template:,
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:
          )
            puts hosted_zone_name
            puts hosted_zone_id
            resources = _resources template
            resources[BASTION_ROLE] = Resources::IAM.role
            resources[BASTION_INSTANCE_PROFILE] =
              Resources::IAM.instance_profile(
                role: BASTION_ROLE
              )
            resources[BASTION_POLICY] = Resources::IAM.policy(
              role: BASTION_ROLE,
              name: BASTION_POLICY,
              statements: [{
                actions: 's3:GetObject',
                resources: "arn:aws:s3:::#{bucket}>/#{config_key}"
              }, {
                actions: 'kms:Decrypt',
                resources: "arn:aws:kms:::key/#{bootstrap.kms_key}"
              }]
            )
            resources[BASTION_SECURITY_GROUP] = Resources::EC2.security_group(
              group_description: 'Bastion security group',
              vpc: VPC,
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
                cidr: bootstrap.vpc.cidr,
                protocol: 'tcp',
                from_port: '0',
                to_port: '65535'
              }, {
                cidr: bootstrap.vpc.cidr,
                protocol: 'udp',
                from_port: '0',
                to_port: '65535'
              }, {
                cidr: bootstrap.vpc.cidr,
                protocol: 'icmp',
                from_port: '-1',
                to_port: '-1'
              }]
            )
            resources[BASTION_INSTANCE] = Resources::EC2.instance(
              scripts: [
                Scripts.hostname(
                  sub_domain: bootstrap.bastion.sub_domain,
                  hosted_zone_name: hosted_zone_name
                )
              ],
              instance_profile: BASTION_INSTANCE_PROFILE,
              availability_zone: bootstrap.vpc.subnets[
                bootstrap.bastion.subnet
              ].availability_zone,
              instance_type: 't2.micro',
              key_name: bootstrap.ec2.key_pair,
              subnet: ref("#{bootstrap.bastion.subnet}#{SUBNET}"),
              associate_public_ip_address: bootstrap.vpc.subnets[
                bootstrap.bastion.subnet
              ].public?,
              name: 'bastion',
              wait_condition_handle: BASTION_WAIT_CONDITION_HANDLE,
              security_group: BASTION_SECURITY_GROUP,
              logical_id: BASTION_INSTANCE,
              source_dest_check: false
            )
            resources[BASTION_WAIT_CONDITION_HANDLE] =
              Resources::CloudFormation.wait_condition_handle
            resources[BASTION_WAIT_CONDITION] =
              Resources::CloudFormation.wait_condition(
                instance: BASTION_INSTANCE,
                wait_condition_handle: BASTION_WAIT_CONDITION_HANDLE
              )
            resources[BASTION_PUBLIC_RECORD_SET] =
              Resources::Route53.record_set(
                hosted_zone_id: hosted_zone_id,
                sub_domain: bootstrap.bastion.sub_domain,
                hosted_zone_name: hosted_zone_name,
                instance: BASTION_INSTANCE,
                attribute: 'PublicIp'
              )
            resources[BASTION_PRIVATE_RECORD_SET] =
              Resources::Route53.record_set(
                hosted_zone_id: Template.ref(PRIVATE_HOSTED_ZONE),
                sub_domain: bootstrap.bastion.sub_domain,
                hosted_zone_name: hosted_zone_name,
                instance: BASTION_INSTANCE,
                attribute: 'PrivateIp'
              )
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          def self._resources(template)
            template[:Resources] ||= {}
          end

          def self._outputs(template)
            template[:Outputs] ||= {}
          end

          def self._mappings(template)
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
            :_resources,
            :_outputs,
            :_mappings
          )
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
