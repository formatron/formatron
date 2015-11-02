require_relative 'template/resources/route53'
require_relative 'template/resources/ec2'
require_relative 'template/resources/iam'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation template JSON
        # rubocop:disable Metrics/ModuleLength
        module Template
          PRIVATE_HOSTED_ZONE = 'privateHostedZone'
          VPC = 'vpc'
          INTERNET_GATEWAY = 'internetGateway'
          VPC_GATEWAY_ATTACHMENT = 'vpcGatewayAttachment'
          PUBLIC_ROUTE_TABLE = 'publicRouteTable'
          PUBLIC_ROUTE = 'publicRoute'
          PRIVATE_ROUTE_TABLE = 'privateRouteTable'
          PRIVATE_ROUTE = 'privateRoute'
          NAT_INSTANCE = 'natInstance'
          SUBNET = 'Subnet'
          SUBNET_ROUTE_TABLE_ASSOCIATION = 'SubnetRouteTableAssociation'
          NAT_ROLE = 'natRole'
          NAT_INSTANCE_PROFILE = 'natInstanceProfile'
          NAT_POLICY = 'natPolicy'
          NAT_SECURITY_GROUP = 'natSecurityGroup'

          def self.create(description)
            {
              AWSTemplateFormatVersion: '2010-09-09',
              Description: "#{description}"
            }
          end

          # rubocop:disable Metrics/MethodLength
          def self.add_private_hosted_zone(
            template:,
            hosted_zone_name:,
            region:
          )
            resources = _resources template
            outputs = _outputs template
            resources[PRIVATE_HOSTED_ZONE] = Resources::Route53.hosted_zone(
              name: hosted_zone_name,
              region: region,
              vpc: VPC
            )
            outputs[PRIVATE_HOSTED_ZONE] = output ref(PRIVATE_HOSTED_ZONE)
          end
          # rubocop:enable Metrics/MethodLength

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
            resources[NAT_INSTANCE] = {
            }
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

          def self.ref(logical_id)
            { Ref: logical_id }
          end

          def self.join(items)
            {
              'Fn::Join'.to_sym => [
                '', items
              ]
            }
          end

          def self.output(value)
            {
              Value: value
            }
          end

          private_class_method(
            :_resources,
            :_outputs
          )
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
