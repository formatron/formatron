require_relative 'template/resources/route53'
require_relative 'template/resources/ec2'
require_relative 'template/resources/iam'
require_relative 'template/resources/cloud_formation'
require_relative 'files'
require 'formatron/aws'

class Formatron
  module CloudFormation
    # Generates CloudFormation template JSON
    # rubocop:disable Metrics/ModuleLength
    module Template
      REGION_MAP = 'regionMap'
      USER = 'User'
      ACCESS_KEY = 'AccessKey'
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
      NETWORK_ACL = 'NetworkAcl'
      SUBNET_NETWORK_ACL_ASSOCIATION = 'SubnetNetworkAclAssociation'
      NETWORK_ACL_ENTRY_VPC_INBOUND = 'NetworkAclEntryVpcInbound'
      NETWORK_ACL_ENTRY_EXTERNAL_INBOUND_TCP =
        'NetworkAclEntryExternalInboundTcp'
      NETWORK_ACL_ENTRY_EXTERNAL_INBOUND_UDP =
        'NetworkAclEntryExternalInboundUdp'
      NETWORK_ACL_ENTRY_OUTBOUND = 'NetworkAclEntryOutbound'
      NETWORK_ACL_ENTRY_EXTERNAL_INBOUND = 'NetworkAclEntryExternalInbound'
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

      EPHEMERAL_PORT_START = 1024
      EPHEMERAL_PORT_END = 65_535

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

      def self.add_user(template:, prefix:, statements:)
        resources = resources template
        resources["#{prefix}#{USER}"] = Resources::IAM.user(
          policy_name: "#{prefix}#{USER}",
          statements: statements
        )
        resources["#{prefix}#{ACCESS_KEY}"] = Resources::IAM.access_key(
          user_name: Template.ref("#{prefix}#{USER}")
        )
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
            subnet: subnet,
            vpc: vpc
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.add_subnet(template:, name:, subnet:, vpc:)
        is_public = subnet.public?
        route_table =
         is_public ? PUBLIC_ROUTE_TABLE : PRIVATE_ROUTE_TABLE
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
        return unless is_public
        acl = subnet.acl
        return if acl.nil?
        source_cidrs = acl.source_cidrs
        return if source_cidrs.nil? || source_cidrs.length == 0
        resources["#{name}#{NETWORK_ACL}"] =
          Resources::EC2.network_acl vpc: VPC
        resources["#{name}#{SUBNET_NETWORK_ACL_ASSOCIATION}"] =
          Resources::EC2.subnet_network_acl_association(
            subnet: "#{name}#{SUBNET}",
            network_acl: "#{name}#{NETWORK_ACL}"
          )
        resources["#{name}#{NETWORK_ACL_ENTRY_VPC_INBOUND}"] =
          Resources::EC2.network_acl_entry(
            network_acl: "#{name}#{NETWORK_ACL}",
            cidr: vpc.cidr,
            egress: false,
            protocol: -1,
            action: 'allow',
            icmp_code: -1,
            icmp_type: -1,
            number: 100
          )
        resources["#{name}#{NETWORK_ACL_ENTRY_EXTERNAL_INBOUND_TCP}"] =
          Resources::EC2.network_acl_entry(
            network_acl: "#{name}#{NETWORK_ACL}",
            cidr: '0.0.0.0/0',
            egress: false,
            protocol: 6,
            action: 'allow',
            start_port: EPHEMERAL_PORT_START,
            end_port: EPHEMERAL_PORT_END,
            number: 200
          )
        resources["#{name}#{NETWORK_ACL_ENTRY_EXTERNAL_INBOUND_UDP}"] =
          Resources::EC2.network_acl_entry(
            network_acl: "#{name}#{NETWORK_ACL}",
            cidr: '0.0.0.0/0',
            egress: false,
            protocol: 17,
            action: 'allow',
            start_port: EPHEMERAL_PORT_START,
            end_port: EPHEMERAL_PORT_END,
            number: 300
          )
        resources["#{name}#{NETWORK_ACL_ENTRY_OUTBOUND}"] =
          Resources::EC2.network_acl_entry(
            network_acl: "#{name}#{NETWORK_ACL}",
            cidr: '0.0.0.0/0',
            egress: true,
            protocol: -1,
            action: 'allow',
            icmp_code: -1,
            icmp_type: -1,
            number: 400
          )
        source_cidrs.each_index do |index|
          source_cidr = source_cidrs[index]
          resources[
            "#{name}#{NETWORK_ACL_ENTRY_EXTERNAL_INBOUND}#{index}"
          ] = Resources::EC2.network_acl_entry(
            network_acl: "#{name}#{NETWORK_ACL}",
            cidr: source_cidr,
            egress: false,
            protocol: -1,
            action: 'allow',
            icmp_code: -1,
            icmp_type: -1,
            number: 500 + index
          )
        end
      end
      # rubocop:enable Metrics/AbcSize
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
          s3_keys: {
            get: [config_key]
          },
          instance: bootstrap.nat,
          bootstrap: bootstrap,
          scripts: [Files.nat(cidr: bootstrap.vpc.cidr)],
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
          s3_keys: {
            get: [config_key]
          },
          instance: bootstrap.bastion,
          bootstrap: bootstrap,
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
      # rubocop:disable Metrics/AbcSize
      def self.add_chef_server(
        template:,
        hosted_zone_id:,
        hosted_zone_name:,
        bootstrap:,
        bucket:,
        user_pem_key:,
        organization_pem_key:,
        ssl_cert_key:,
        ssl_key_key:,
        config_key:
      )
        chef_server = bootstrap.chef_server
        organization = chef_server.organization
        cookbooks_bucket = chef_server.cookbooks_bucket
        add_user(
          template: template,
          prefix: CHEF_SERVER,
          statements: [{
            actions: ['s3:PutObject', 's3:GetObject', 's3:DeleteObject'],
            resources: "arn:aws:s3:::#{cookbooks_bucket}/*"
          }, {
            actions: ['s3:ListBucket'],
            resources: "arn:aws:s3:::#{cookbooks_bucket}"
          }]
        )
        add_instance(
          template: template,
          prefix: CHEF_SERVER,
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
            'REGION' => Template.ref('AWS::Region'),
            'ACCESS_KEY_ID' => Template.ref("#{CHEF_SERVER}#{ACCESS_KEY}"),
            'SECRET_ACCESS_KEY' => Template.get_attribute(
              "#{CHEF_SERVER}#{ACCESS_KEY}",
              'SecretAccessKey'
            )
          },
          scripts: [Files.chef_server(
            username: chef_server.username,
            first_name: chef_server.first_name,
            last_name: chef_server.last_name,
            email: chef_server.email,
            password: chef_server.password,
            organization_short_name: organization.short_name,
            organization_full_name: organization.full_name,
            bucket: bucket,
            user_pem_key: user_pem_key,
            organization_pem_key: organization_pem_key,
            kms_key: bootstrap.kms_key,
            chef_server_version: chef_server.version,
            ssl_cert_key: ssl_cert_key,
            ssl_key_key: ssl_key_key,
            cookbooks_bucket: cookbooks_bucket
          )],
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
          source_dest_check: true,
          instance_type: 't2.medium'
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength
      def self.add_instance(
        template:,
        prefix:,
        bucket:,
        s3_keys:,
        instance:,
        bootstrap:,
        ingress_rules:,
        script_variables: nil,
        scripts: nil,
        files: nil,
        public_hosted_zone_id:,
        private_hosted_zone_id:,
        hosted_zone_name:,
        source_dest_check:,
        instance_type: 't2.micro'
      )
        statements = [{
          actions: ['kms:Decrypt', 'kms:Encrypt', 'kms:GenerateDataKey*'],
          resources: Template.join(
            'arn:aws:kms:',
            Template.ref('AWS::Region'),
            ':',
            Template.ref('AWS::AccountId'),
            ":key/#{bootstrap.kms_key}"
          )
        }]
        statements.push(
          actions: 's3:GetObject',
          resources: s3_keys[:get].collect do |s3_key|
            "arn:aws:s3:::#{bucket}/#{s3_key}"
          end
        ) unless s3_keys[:get].nil?
        statements.push(
          actions: 's3:PutObject',
          resources: s3_keys[:put].collect do |s3_key|
            "arn:aws:s3:::#{bucket}/#{s3_key}"
          end
        ) unless s3_keys[:put].nil?
        resources = resources template
        resources["#{prefix}#{ROLE}"] = Resources::IAM.role
        resources["#{prefix}#{INSTANCE_PROFILE}"] =
          Resources::IAM.instance_profile(
            role: "#{prefix}#{ROLE}"
          )
        resources["#{prefix}#{POLICY}"] = Resources::IAM.policy(
          role: "#{prefix}#{ROLE}",
          name: "#{prefix}#{POLICY}",
          statements: statements
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
          script_variables: script_variables,
          scripts: [
            Files.hostname(
              sub_domain: instance.sub_domain,
              hosted_zone_name: hosted_zone_name
            )
          ].concat(scripts || []),
          files: files,
          instance_profile: "#{prefix}#{INSTANCE_PROFILE}",
          availability_zone: bootstrap.vpc.subnets[
            instance.subnet
          ].availability_zone,
          instance_type: instance_type,
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
