require 'formatron/cloud_formation/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # generates CloudFormation security group resource
            # rubocop:disable Metrics/ClassLength
            class SecurityGroup
              SECURITY_GROUP_PREFIX = 'securityGroup'

              # rubocop:disable Metrics/MethodLength
              def initialize(
                os:,
                security_group:,
                instance_guid:,
                vpc_guid:,
                vpc_cidr:
              )
                @os = os
                @security_group = security_group
                @vpc_guid = vpc_guid
                @cidr = vpc_cidr
                @guid = instance_guid
                @security_group_id = "#{SECURITY_GROUP_PREFIX}#{@guid}"
                @vpc_id = "#{VPC::VPC_PREFIX}#{@vpc_guid}"
                @open_tcp_ports =
                  @security_group.open_tcp_port unless @security_group.nil?
                @open_udp_ports =
                  @security_group.open_udp_port unless @security_group.nil?
              end
              # rubocop:enable Metrics/MethodLength

              # rubocop:disable Metrics/MethodLength
              def merge(resources:)
                if @os.eql? 'windows'
                  ingress_rules = _base_windows_ingress_rules
                else
                  ingress_rules = _base_ingress_rules
                end
                ingress_rules.concat(
                  @open_tcp_ports.collect do |port|
                    {
                      cidr: '0.0.0.0/0',
                      protocol: 'tcp',
                      from_port: port,
                      to_port: port
                    }
                  end
                ) unless @open_tcp_ports.nil?
                ingress_rules.concat(
                  @open_udp_ports.collect do |port|
                    {
                      cidr: '0.0.0.0/0',
                      protocol: 'udp',
                      from_port: port,
                      to_port: port
                    }
                  end
                ) unless @open_udp_ports.nil?
                resources[@security_group_id] = Resources::EC2.security_group(
                  group_description: 'Formatron instance security group',
                  vpc: @vpc_id,
                  egress: _base_egress_rules,
                  ingress: ingress_rules
                )
              end
              # rubocop:enable Metrics/MethodLength

              # rubocop:disable Metrics/MethodLength
              def _base_egress_rules
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
              def _base_ingress_rules
                [{
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
              end
              # rubocop:enable Metrics/MethodLength

              # rubocop:disable Metrics/MethodLength
              def _base_windows_ingress_rules
                [{
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
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'tcp',
                  from_port: '3389',
                  to_port: '3389'
                }, {
                  cidr: '0.0.0.0/0',
                  protocol: 'tcp',
                  from_port: '5985',
                  to_port: '5985'
                }]
              end
              # rubocop:enable Metrics/MethodLength

              private(
                :_base_egress_rules,
                :_base_ingress_rules,
                :_base_windows_ingress_rules
              )
            end
            # rubocop:enable Metrics/ClassLength
          end
        end
      end
    end
  end
end
