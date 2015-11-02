require_relative '../../template'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
          module Resources
            # Generates CloudFormation template EC2 resources
            # rubocop:disable Metrics/ModuleLength
            module EC2
              def self.vpc(cidr:)
                {
                  Type: 'AWS::EC2::VPC',
                  Properties: {
                    CidrBlock: cidr,
                    EnableDnsSupport: true,
                    EnableDnsHostnames: true,
                    InstanceTenancy: 'default'
                  }
                }
              end

              def self.internet_gateway
                {
                  Type: 'AWS::EC2::InternetGateway'
                }
              end

              def self.vpc_gateway_attachment(vpc:, gateway:)
                {
                  Type: 'AWS::EC2::VPCGatewayAttachment',
                  Properties: {
                    InternetGatewayId: Template.ref(gateway),
                    VpcId: Template.ref(vpc)
                  }
                }
              end

              def self.route_table(vpc:)
                {
                  Type: 'AWS::EC2::RouteTable',
                  Properties: {
                    VpcId: Template.ref(vpc)
                  }
                }
              end

              # rubocop:disable Metrics/MethodLength
              def self.route(
                route_table:,
                instance: nil,
                internet_gateway: nil,
                vpc_gateway_attachment: nil
              )
                properties = {
                  RouteTableId: Template.ref(route_table),
                  DestinationCidrBlock: '0.0.0.0/0'
                }
                properties[:GatewayId] =
                  Template.ref internet_gateway unless internet_gateway.nil?
                properties[:InstanceId] =
                  Template.ref instance unless instance.nil?
                route = {
                  Type: 'AWS::EC2::Route',
                  Properties: properties
                }
                route[:DependsOn] =
                  vpc_gateway_attachment unless vpc_gateway_attachment.nil?
                route
              end
              # rubocop:enable Metrics/MethodLength

              def self.subnet(vpc:, cidr:, availability_zone:)
                {
                  Type: 'AWS::EC2::Subnet',
                  Properties: {
                    VpcId: Template.ref(vpc),
                    CidrBlock: cidr,
                    AvailabilityZone: availability_zone
                  }
                }
              end

              def self.subnet_route_table_association(route_table:, subnet:)
                {
                  Type: 'AWS::EC2::SubnetRouteTableAssociation',
                  Properties: {
                    RouteTableId: Template.ref(route_table),
                    SubnetId: Template.ref(subnet)
                  }
                }
              end

              # rubocop:disable Metrics/MethodLength
              def self.security_group(
                group_description:,
                vpc:,
                egress:,
                ingress:
              )
                {
                  Type: 'AWS::EC2::SecurityGroup',
                  Properties: {
                    GroupDescription: group_description,
                    VpcId: Template.ref(vpc),
                    SecurityGroupEgress: egress.collect do |rule|
                      {
                        CidrIp: rule[:cidr],
                        IpProtocol: rule[:protocol],
                        FromPort: rule[:from_port],
                        ToPort: rule[:to_port]
                      }
                    end,
                    SecurityGroupIngress: ingress.collect do |rule|
                      {
                        CidrIp: rule[:cidr],
                        IpProtocol: rule[:protocol],
                        FromPort: rule[:from_port],
                        ToPort: rule[:to_port]
                      }
                    end
                  }
                }
              end
              # rubocop:enable Metrics/MethodLength

              # rubocop:disable Metrics/MethodLength
              def self.security_group_egress(
                security_group:,
                cidr:,
                protocol:,
                from_port:,
                to_port:
              )
                {
                  Type: 'AWS::EC2::SecurityGroupEgress',
                  Properties: {
                    GroupId: Template.ref(security_group),
                    CidrIp: cidr,
                    IpProtocol: protocol,
                    FromPort: from_port,
                    ToPort: to_port
                  }
                }
              end
              # rubocop:enable Metrics/MethodLength

              # rubocop:disable Metrics/MethodLength
              def self.security_group_ingress(
                security_group:,
                cidr:,
                protocol:,
                from_port:,
                to_port:
              )
                {
                  Type: 'AWS::EC2::SecurityGroupIngress',
                  Properties: {
                    GroupId: Template.ref(security_group),
                    CidrIp: cidr,
                    IpProtocol: protocol,
                    FromPort: from_port,
                    ToPort: to_port
                  }
                }
              end
              # rubocop:enable Metrics/MethodLength
            end
            # rubocop:enable Metrics/ModuleLength
          end
        end
      end
    end
  end
end
