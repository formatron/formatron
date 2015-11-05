require_relative '../../template'

class Formatron
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

          # rubocop:disable Metrics/MethodLength
          def self.subnet(vpc:, cidr:, availability_zone:)
            {
              Type: 'AWS::EC2::Subnet',
              Properties: {
                VpcId: Template.ref(vpc),
                CidrBlock: cidr,
                AvailabilityZone: Template.join(
                  Template.ref('AWS::Region'),
                  availability_zone
                )
              }
            }
          end
          # rubocop:enable Metrics/MethodLength

          def self.subnet_route_table_association(route_table:, subnet:)
            {
              Type: 'AWS::EC2::SubnetRouteTableAssociation',
              Properties: {
                RouteTableId: Template.ref(route_table),
                SubnetId: Template.ref(subnet)
              }
            }
          end

          def self.network_acl(vpc:)
            {
              Type: 'AWS::EC2::NetworkAcl',
              Properties: {
                VpcId: Template.ref(vpc)
              }
            }
          end

          def self.subnet_network_acl_association(subnet:, network_acl:)
            {
              Type: 'AWS::EC2::SubnetNetworkAclAssociation',
              Properties: {
                SubnetId: Template.ref(subnet),
                NetworkAclId: Template.ref(network_acl)
              }
            }
          end

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          def self.network_acl_entry(
            network_acl:,
            cidr:,
            egress:,
            protocol:,
            action:,
            icmp_code: nil,
            icmp_type: nil,
            start_port: nil,
            end_port: nil,
            number:
          )
            resource = {
              Type: 'AWS::EC2::NetworkAclEntry',
              Properties: {
                NetworkAclId: Template.ref(network_acl),
                CidrBlock: cidr,
                Egress: egress,
                Protocol: protocol,
                RuleAction: action,
                RuleNumber: number
              }
            }
            resource[:Properties][:Icmp] = {
              Code: icmp_code,
              Type: icmp_type
            } unless icmp_code.nil?
            resource[:Properties][:PortRange] = {
              From: start_port,
              To: end_port
            } unless start_port.nil?
            resource
          end
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

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

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          # rubocop:disable Metrics/AbcSize
          def self.instance(
            scripts: nil,
            script_variables: nil,
            files: nil,
            instance_profile:,
            availability_zone:,
            instance_type:,
            key_name:,
            subnet:,
            associate_public_ip_address:,
            name:,
            wait_condition_handle:,
            security_group:,
            logical_id:,
            source_dest_check:
          )
            files ||= {}
            scripts.each_index do |index|
              files["/tmp/formatron/script-#{index}.sh"] = {
                content: scripts[index],
                mode: '000755',
                owner: 'root',
                group: 'root'
              }
            end unless scripts.nil?
            script_variables_content =
              script_variables.reduce([]) do |content, (key, value)|
                content.concat(["#{key}=", value, "\n"])
              end unless script_variables.nil?
            files['/tmp/formatron/script-variables'] = {
              content: Template.join(*script_variables_content),
              mode: '000644',
              owner: 'root',
              group: 'root'
            } unless script_variables_content.nil?
            {
              Type: 'AWS::EC2::Instance',
              Metadata: {
                Comment1: 'Create setup scripts',
                'AWS::CloudFormation::Init' => {
                  config: {
                    files: files
                  }
                }
              },
              Properties: {
                IamInstanceProfile: Template.ref(instance_profile),
                AvailabilityZone: Template.join(
                  Template.ref('AWS::Region'),
                  availability_zone
                ),
                ImageId: Template.find_in_map(
                  Template::REGION_MAP,
                  Template.ref('AWS::Region'),
                  'ami'
                ),
                SourceDestCheck: source_dest_check,
                InstanceType: instance_type,
                KeyName: key_name,
                NetworkInterfaces: [{
                  AssociatePublicIpAddress: associate_public_ip_address,
                  DeviceIndex: '0',
                  DeleteOnTermination: true,
                  GroupSet: [Template.ref(security_group)],
                  SubnetId: subnet
                }],
                Tags: [{
                  Key: 'Name',
                  Value: name
                }],
                UserData: Template.base_64(
                  Template.join(
                    # rubocop:disable Metrics/LineLength
                    "#!/bin/bash -v\n",
                    "function error_exit\n",
                    "{\n",
                    "  cfn-signal -e 1 -r \"$1\" '", Template.ref(wait_condition_handle), "'\n",
                    "  exit 1\n",
                    "}\n",
                    "apt-get -y update\n",
                    "apt-get -y install python-setuptools\n",
                    "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                    "export PATH=$PATH:/opt/aws/bin\n",
                    'cfn-init --region ', Template.ref('AWS::Region'),
                    '    -v -s ', Template.ref('AWS::StackName'), " -r #{logical_id} ",
                    " || error_exit 'Failed to run cfn-init'\n",
                    "for file in /tmp/formatron/script-*.sh; do\n",
                    "  $file || error_exit \"failed to run Formatron setup script: $file\"\n",
                    "done\n",
                    "# If all went well, signal success\n",
                    "cfn-signal -e $? -r 'Formatron instance configuration complete' '", Template.ref(wait_condition_handle), "'\n"
                  # rubocop:enable Metrics/LineLength
                  )
                )
              }
            }
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end
