require 'formatron/cloud_formation/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation ACL resources
          # rubocop:disable Metrics/ClassLength
          class ACL
            NETWORK_ACL_PREFIX = 'networkAcl'
            SUBNET_NETWORK_ACL_ASSOCIATION_PREFIX =
              'subnetNetworkAclAssociation'
            VPC_INBOUND_NETWORK_ACL_ENTRY_PREFIX =
              'vpcInboundNetworkAclEntry'
            EXTERNAL_INBOUND_TCP_NETWORK_ACL_ENTRY_PREFIX =
              'externalInboundTcpNetworkAclEntry'
            EXTERNAL_INBOUND_UDP_NETWORK_ACL_ENTRY_PREFIX =
              'externalInboundUdpNetworkAclEntry'
            OUTBOUND_NETWORK_ACL_ENTRY_PREFIX =
              'outboundNetworkAclEntry'
            EXTERNAL_INBOUND_NETWORK_ACL_ENTRY_PREFIX =
              'externalInboundNetworkAclEntry'

            EPHEMERAL_PORT_START = 1024
            EPHEMERAL_PORT_END = 65_535

            # rubocop:disable Metrics/MethodLength
            def initialize(acl:, subnet_guid:, vpc_guid:, vpc_cidr:)
              @acl = acl
              @subnet_guid = subnet_guid
              @vpc_guid = vpc_guid
              @vpc_cidr = vpc_cidr
              @network_acl_id = "#{NETWORK_ACL_PREFIX}#{@subnet_guid}"
              @subnet_network_acl_association_id =
                "#{SUBNET_NETWORK_ACL_ASSOCIATION_PREFIX}#{@subnet_guid}"
              @vpc_id = "#{VPC::VPC_PREFIX}#{@vpc_guid}"
              @subnet_id = "#{Subnet::SUBNET_PREFIX}#{@subnet_guid}"
              @network_acl_entry_vpc_inbound_id =
                "#{VPC_INBOUND_NETWORK_ACL_ENTRY_PREFIX}#{@subnet_guid}"
              @network_acl_entry_external_inbound_tcp_id =
                "#{EXTERNAL_INBOUND_TCP_NETWORK_ACL_ENTRY_PREFIX}" \
                "#{@subnet_guid}"
              @network_acl_entry_external_inbound_udp_id =
                "#{EXTERNAL_INBOUND_UDP_NETWORK_ACL_ENTRY_PREFIX}" \
                "#{@subnet_guid}"
              @network_acl_entry_outbound_id =
                "#{OUTBOUND_NETWORK_ACL_ENTRY_PREFIX}#{@subnet_guid}"
              @source_cidrs = @acl.source_cidr
            end
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def merge(resources:)
              return if @source_cidrs.length == 0
              resources[@network_acl_id] = Resources::EC2.network_acl(
                vpc: @vpc_id
              )
              resources[@subnet_network_acl_association_id] =
                Resources::EC2.subnet_network_acl_association(
                  subnet: @subnet_id,
                  network_acl: @network_acl_id
                )
              _add_default_rules resources
              _add_source_cidrs resources
            end
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_default_rules(resources)
              resources[@network_acl_entry_vpc_inbound_id] =
                Resources::EC2.network_acl_entry(
                  network_acl: @network_acl_id,
                  cidr: @vpc_cidr,
                  egress: false,
                  protocol: -1,
                  action: 'allow',
                  icmp_code: -1,
                  icmp_type: -1,
                  number: 100
                )
              resources[@network_acl_entry_external_inbound_tcp_id] =
                Resources::EC2.network_acl_entry(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: false,
                  protocol: 6,
                  action: 'allow',
                  start_port: EPHEMERAL_PORT_START,
                  end_port: EPHEMERAL_PORT_END,
                  number: 200
                )
              resources[@network_acl_entry_external_inbound_udp_id] =
                Resources::EC2.network_acl_entry(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: false,
                  protocol: 17,
                  action: 'allow',
                  start_port: EPHEMERAL_PORT_START,
                  end_port: EPHEMERAL_PORT_END,
                  number: 300
                )
              resources[@network_acl_entry_outbound_id] =
                Resources::EC2.network_acl_entry(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: true,
                  protocol: -1,
                  action: 'allow',
                  icmp_code: -1,
                  icmp_type: -1,
                  number: 400
                )
            end
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_source_cidrs(resources)
              @source_cidrs.each_index do |index|
                source_cidr = @source_cidrs[index]
                resources[
                  "#{EXTERNAL_INBOUND_NETWORK_ACL_ENTRY_PREFIX}" \
                  "#{index}#{@subnet_guid}"
                ] = Resources::EC2.network_acl_entry(
                  network_acl: @network_acl_id,
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
            # rubocop:enable Metrics/MethodLength

            private(
              :_add_default_rules,
              :_add_source_cidrs
            )
          end
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
