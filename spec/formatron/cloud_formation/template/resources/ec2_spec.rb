require 'spec_helper'
require 'formatron/cloud_formation' \
        '/template/resources/ec2'

class Formatron
  module CloudFormation
    module Template
      # namespacing for tests
      # rubocop:disable Metrics/ModuleLength
      module Resources
        describe EC2 do
          describe '::vpc' do
            it 'should return a VPC resource' do
              cidr = 'cidr'
              expect(EC2.vpc(cidr: cidr)).to eql(
                Type: 'AWS::EC2::VPC',
                Properties: {
                  CidrBlock: cidr,
                  EnableDnsSupport: true,
                  EnableDnsHostnames: true,
                  InstanceTenancy: 'default'
                }
              )
            end
          end

          describe '::internet_gateway' do
            it 'should return an InternetGateway resource' do
              expect(EC2.internet_gateway).to eql(
                Type: 'AWS::EC2::InternetGateway'
              )
            end
          end

          describe '::vpc_gateway_attachment' do
            it 'should return a VPCGatewayAttachment resource' do
              vpc = 'vpc'
              gateway = 'gateway'
              expect(
                EC2.vpc_gateway_attachment(
                  vpc: vpc,
                  gateway: gateway
                )
              ).to eql(
                Type: 'AWS::EC2::VPCGatewayAttachment',
                Properties: {
                  InternetGatewayId: { Ref: gateway },
                  VpcId: { Ref: vpc }
                }
              )
            end
          end

          describe '::route_table' do
            it 'should return a RouteTable resource' do
              vpc = 'vpc'
              expect(
                EC2.route_table(
                  vpc: vpc
                )
              ).to eql(
                Type: 'AWS::EC2::RouteTable',
                Properties: {
                  VpcId: { Ref: vpc }
                }
              )
            end
          end

          describe '::route' do
            context 'with gateway' do
              it 'should return a Route resource' do
                route_table = 'route_table'
                internet_gateway = 'internet_gateway'
                vpc_gateway_attachment = 'vpc_gateway_attachment'
                expect(
                  EC2.route(
                    vpc_gateway_attachment: vpc_gateway_attachment,
                    route_table: route_table,
                    internet_gateway: internet_gateway
                  )
                ).to eql(
                  Type: 'AWS::EC2::Route',
                  DependsOn: vpc_gateway_attachment,
                  Properties: {
                    RouteTableId: { Ref: route_table },
                    DestinationCidrBlock: '0.0.0.0/0',
                    GatewayId: { Ref: internet_gateway }
                  }
                )
              end
            end

            context 'with instance' do
              it 'should return a Route resource' do
                route_table = 'route_table'
                instance = 'instance'
                expect(
                  EC2.route(
                    route_table: route_table,
                    instance: instance
                  )
                ).to eql(
                  Type: 'AWS::EC2::Route',
                  Properties: {
                    RouteTableId: { Ref: route_table },
                    DestinationCidrBlock: '0.0.0.0/0',
                    InstanceId: { Ref: instance }
                  }
                )
              end
            end
          end

          describe '::subnet' do
            it 'should return a Subnet resource' do
              vpc = 'vpc'
              cidr = 'cidr'
              availability_zone = 'availability_zone'
              expect(
                EC2.subnet(
                  vpc: vpc,
                  cidr: cidr,
                  availability_zone: availability_zone
                )
              ).to eql(
                Type: 'AWS::EC2::Subnet',
                Properties: {
                  VpcId: { Ref: vpc },
                  CidrBlock: cidr,
                  AvailabilityZone: {
                    'Fn::Join' => [
                      '', [
                        { Ref: 'AWS::Region' },
                        availability_zone
                      ]
                    ]
                  }
                }
              )
            end
          end

          describe '::subnet_route_table_association' do
            it 'should return a SubnetRouteTableAssociation resource' do
              route_table = 'route_table'
              subnet = 'subnet'
              expect(
                EC2.subnet_route_table_association(
                  route_table: route_table,
                  subnet: subnet
                )
              ).to eql(
                Type: 'AWS::EC2::SubnetRouteTableAssociation',
                Properties: {
                  RouteTableId: { Ref: route_table },
                  SubnetId: { Ref: subnet }
                }
              )
            end
          end

          describe '::network_acl' do
            it 'should return a NetworkAcl resource' do
              vpc = 'vpc'
              expect(
                EC2.network_acl(
                  vpc: vpc
                )
              ).to eql(
                Type: 'AWS::EC2::NetworkAcl',
                Properties: {
                  VpcId: { Ref: vpc }
                }
              )
            end
          end

          describe '::subnet_network_acl_association' do
            it 'should return a SubnetNetworkAclAssociation resource' do
              subnet = 'subnet'
              network_acl = 'network_acl'
              expect(
                EC2.subnet_network_acl_association(
                  subnet: subnet,
                  network_acl: network_acl
                )
              ).to eql(
                Type: 'AWS::EC2::SubnetNetworkAclAssociation',
                Properties: {
                  SubnetId: { Ref: subnet },
                  NetworkAclId: { Ref: network_acl }
                }
              )
            end
          end

          describe '::network_acl_entry' do
            it 'should return a NetworkAclEntry resource' do
              network_acl = 'network_acl'
              cidr = 'cidr'
              egress = 'egress'
              protocol = 'protocol'
              action = 'action'
              icmp_code = 'icmp_code'
              icmp_type = 'icmp_type'
              start_port = 'start_port'
              end_port = 'end_port'
              number = 'number'
              expect(
                EC2.network_acl_entry(
                  network_acl: network_acl,
                  cidr: cidr,
                  egress: egress,
                  protocol: protocol,
                  action: action,
                  icmp_code: icmp_code,
                  icmp_type: icmp_type,
                  start_port: start_port,
                  end_port: end_port,
                  number: number
                )
              ).to eql(
                Type: 'AWS::EC2::NetworkAclEntry',
                Properties: {
                  NetworkAclId: { Ref: network_acl },
                  CidrBlock: cidr,
                  Egress: egress,
                  Icmp: {
                    Code: icmp_code,
                    Type: icmp_type
                  },
                  Protocol: protocol,
                  PortRange: {
                    From: start_port,
                    To: end_port
                  },
                  RuleAction: action,
                  RuleNumber: number
                }
              )
            end
          end

          describe '::security_group' do
            it 'should return a SecurityGroup resource' do
              group_description = 'group_description'
              vpc = 'vpc'
              cidr = 'cidr'
              protocol = 'protocol'
              from_port = 'from_port'
              to_port = 'to_port'
              expect(
                EC2.security_group(
                  group_description: group_description,
                  vpc: vpc,
                  egress: [{
                    cidr: cidr,
                    protocol: protocol,
                    from_port: from_port,
                    to_port: to_port
                  }],
                  ingress: [{
                    cidr: cidr,
                    protocol: protocol,
                    from_port: from_port,
                    to_port: to_port
                  }]
                )
              ).to eql(
                Type: 'AWS::EC2::SecurityGroup',
                Properties: {
                  GroupDescription: group_description,
                  VpcId: { Ref: vpc },
                  SecurityGroupEgress: [{
                    CidrIp: cidr,
                    IpProtocol: protocol,
                    FromPort: from_port,
                    ToPort: to_port
                  }],
                  SecurityGroupIngress: [{
                    CidrIp: cidr,
                    IpProtocol: protocol,
                    FromPort: from_port,
                    ToPort: to_port
                  }]
                }
              )
            end
          end

          describe '::security_group_egress' do
            it 'should return a SecurityGroupEgress resource' do
              security_group = 'security_group'
              cidr = 'cidr'
              protocol = 'protocol'
              from_port = 'from_port'
              to_port = 'to_port'
              expect(
                EC2.security_group_egress(
                  security_group: security_group,
                  cidr: cidr,
                  protocol: protocol,
                  from_port: from_port,
                  to_port: to_port
                )
              ).to eql(
                Type: 'AWS::EC2::SecurityGroupEgress',
                Properties: {
                  GroupId: { Ref: security_group },
                  CidrIp: cidr,
                  IpProtocol: protocol,
                  FromPort: from_port,
                  ToPort: to_port
                }
              )
            end
          end

          describe '::security_group_ingress' do
            it 'should return a SecurityGroupIngress resource' do
              security_group = 'security_group'
              cidr = 'cidr'
              protocol = 'protocol'
              from_port = 'from_port'
              to_port = 'to_port'
              expect(
                EC2.security_group_ingress(
                  security_group: security_group,
                  cidr: cidr,
                  protocol: protocol,
                  from_port: from_port,
                  to_port: to_port
                )
              ).to eql(
                Type: 'AWS::EC2::SecurityGroupIngress',
                Properties: {
                  GroupId: { Ref: security_group },
                  CidrIp: cidr,
                  IpProtocol: protocol,
                  FromPort: from_port,
                  ToPort: to_port
                }
              )
            end
          end

          describe '::instance' do
            it 'should return an Instance resource' do
              hostname_sh = 'hostname_sh'
              nat_sh = 'nat_sh'
              script_variables = {
                variable1: 'value1',
                variable2: 'value2'
              }
              script_variables_content = {
                'Fn::Join' => [
                  '', [
                    'variable1=',
                    'value1',
                    "\n",
                    'variable2=',
                    'value2',
                    "\n"
                  ]
                ]
              }
              scripts = [
                hostname_sh,
                nat_sh
              ]
              file = 'file'
              files = {
                file: file
              }
              instance_profile = 'instance_profile'
              availability_zone = 'availability_zone'
              instance_type = 'instance_type'
              key_name = 'key_name'
              subnet = 'subnet'
              associate_public_ip_address = 'associate_public_ip_address'
              name = 'name'
              wait_condition_handle = 'wait_condition_handle'
              security_group = 'security_group'
              logical_id = 'logical_id'
              source_dest_check = 'source_dest_check'
              expect(
                EC2.instance(
                  scripts: scripts,
                  script_variables: script_variables,
                  files: files,
                  instance_profile: instance_profile,
                  availability_zone: availability_zone,
                  instance_type: instance_type,
                  key_name: key_name,
                  subnet: subnet,
                  associate_public_ip_address: associate_public_ip_address,
                  name: name,
                  wait_condition_handle: wait_condition_handle,
                  security_group: security_group,
                  logical_id: logical_id,
                  source_dest_check: source_dest_check
                )
              ).to eql(
                Type: 'AWS::EC2::Instance',
                Metadata: {
                  Comment1: 'Create setup scripts',
                  'AWS::CloudFormation::Init' => {
                    config: {
                      files: {
                        '/tmp/formatron/script-variables' => {
                          content: script_variables_content,
                          mode: '000644',
                          owner: 'root',
                          group: 'root'
                        },
                        '/tmp/formatron/script-0.sh' => {
                          content: hostname_sh,
                          mode: '000755',
                          owner: 'root',
                          group: 'root'
                        },
                        '/tmp/formatron/script-1.sh' => {
                          content: nat_sh,
                          mode: '000755',
                          owner: 'root',
                          group: 'root'
                        },
                        file: file
                      }
                    }
                  }
                },
                Properties: {
                  IamInstanceProfile: { Ref: instance_profile },
                  AvailabilityZone: {
                    'Fn::Join' => [
                      '', [
                        { Ref: 'AWS::Region' },
                        availability_zone
                      ]
                    ]
                  },
                  ImageId: {
                    'Fn::FindInMap' => [
                      'regionMap',
                      { Ref: 'AWS::Region' },
                      'ami'
                    ]
                  },
                  SourceDestCheck: source_dest_check,
                  InstanceType: instance_type,
                  KeyName: key_name,
                  NetworkInterfaces: [{
                    AssociatePublicIpAddress: associate_public_ip_address,
                    DeviceIndex: '0',
                    DeleteOnTermination: true,
                    GroupSet: [{ Ref: security_group }],
                    SubnetId: subnet
                  }],
                  Tags: [{
                    Key: 'Name',
                    Value: name
                  }],
                  UserData: {
                    'Fn::Base64' => {
                      'Fn::Join' => [
                        '', [
                          # rubocop:disable Metrics/LineLength
                          "#!/bin/bash -v\n",
                          "function error_exit\n",
                          "{\n",
                          "  cfn-signal -e 1 -r \"$1\" '", { Ref: wait_condition_handle }, "'\n",
                          "  exit 1\n",
                          "}\n",
                          "apt-get -y update\n",
                          "apt-get -y install python-setuptools\n",
                          "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                          "export PATH=$PATH:/opt/aws/bin\n",
                          'cfn-init --region ', { Ref: 'AWS::Region' },
                          '    -v -s ', { Ref: 'AWS::StackName' }, " -r #{logical_id} ",
                          " || error_exit 'Failed to run cfn-init'\n",
                          "for file in /tmp/formatron/script-*.sh; do\n",
                          "  $file || error_exit \"failed to run Formatron setup script: $file\"\n",
                          "done\n",
                          "# If all went well, signal success\n",
                          "cfn-signal -e $? -r 'Formatron instance configuration complete' '", { Ref: wait_condition_handle }, "'\n"
                          # rubocop:enable Metrics/LineLength
                        ]
                      ]
                    }
                  }
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
