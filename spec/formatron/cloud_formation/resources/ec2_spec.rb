require 'spec_helper'
require 'formatron/cloud_formation' \
        '/resources/ec2'

class Formatron
  module CloudFormation
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
            map_public_ip_on_launch = 'map_public_ip_on_launch'
            expect(
              EC2.subnet(
                vpc: vpc,
                cidr: cidr,
                availability_zone: availability_zone,
                map_public_ip_on_launch: map_public_ip_on_launch
              )
            ).to eql(
              Type: 'AWS::EC2::Subnet',
              Properties: {
                VpcId: { Ref: vpc },
                CidrBlock: cidr,
                MapPublicIpOnLaunch: map_public_ip_on_launch,
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

        describe '::block_device_mapping' do
          it 'should return a block device mapping entry' do
            device = 'device'
            size = 'size'
            type = 'type'
            iops = 'iops'
            expect(
              EC2.block_device_mapping(
                device: device,
                size: size,
                type: type,
                iops: iops
              )
            ).to eql(
              DeviceName: device,
              Ebs: {
                VolumeType: type,
                Iops: iops,
                VolumeSize: size
              }
            )
          end
        end

        describe '::volume' do
          it 'should return a Volume resource' do
            size = 'size'
            type = 'type'
            iops = 'iops'
            availability_zone = 'availability_zone'
            expect(
              EC2.volume(
                availability_zone: availability_zone,
                size: size,
                type: type,
                iops: iops
              )
            ).to eql(
              Type: 'AWS::EC2::Volume',
              Properties: {
                AvailabilityZone: availability_zone,
                Iops: iops,
                Size: size,
                VolumeType: type
              }
            )
          end
        end

        describe '::volume_attachment' do
          it 'should return a VolumeAttachment resource' do
            device = 'device'
            instance = 'instance'
            volume = 'volume'
            expect(
              EC2.volume_attachment(
                device: device,
                instance: instance,
                volume: volume
              )
            ).to eql(
              Type: 'AWS::EC2::VolumeAttachment',
              Properties: {
                Device: device,
                InstanceId: { Ref: instance },
                VolumeId: { Ref: volume }
              }
            )
          end
        end

        describe '::instance' do
          it 'should return an Instance resource' do
            instance_profile = 'instance_profile'
            availability_zone = 'availability_zone'
            instance_type = 'instance_type'
            key_name = 'key_name'
            subnet = 'subnet'
            name = 'name'
            wait_condition_handle = 'wait_condition_handle'
            security_group = 'security_group'
            logical_id = 'logical_id'
            source_dest_check = 'source_dest_check'
            os = 'os'
            administrator_name = 'administrator_name'
            administrator_password = 'administrator_password'
            expect(
              EC2.instance(
                instance_profile: instance_profile,
                availability_zone: availability_zone,
                instance_type: instance_type,
                key_name: key_name,
                administrator_name: administrator_name,
                administrator_password: administrator_password,
                subnet: subnet,
                name: name,
                wait_condition_handle: wait_condition_handle,
                security_group: security_group,
                logical_id: logical_id,
                source_dest_check: source_dest_check,
                os: os
              )
            ).to eql(
              Type: 'AWS::EC2::Instance',
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
                    os
                  ]
                },
                SourceDestCheck: source_dest_check,
                InstanceType: instance_type,
                KeyName: key_name,
                SubnetId: { Ref: subnet },
                SecurityGroupIds: [{ Ref: security_group }],
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
                        "apt-get -y update\n",
                        "apt-get -y install python-setuptools\n",
                        "easy_install https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz\n",
                        "export PATH=$PATH:/opt/aws/bin\n",
                        'cfn-init --region ', { Ref: 'AWS::Region' },
                        '    -v -s ', { Ref: 'AWS::StackName' }, " -r #{logical_id}\n",
                        "cfn-signal -e $? -r 'Formatron instance configuration complete' '", { Ref: wait_condition_handle }, "'\n"
                        # rubocop:enable Metrics/LineLength
                      ]
                    ]
                  }
                }
              }
            )
          end

          context 'when os is windows' do
            # rubocop:disable Metrics/LineLength
            it 'should return an Instance resource with user data for windows' do
              instance_profile = 'instance_profile'
              availability_zone = 'availability_zone'
              instance_type = 'instance_type'
              key_name = 'key_name'
              subnet = 'subnet'
              name = 'name'
              wait_condition_handle = 'wait_condition_handle'
              security_group = 'security_group'
              logical_id = 'logical_id'
              source_dest_check = 'source_dest_check'
              os = 'windows'
              administrator_name = 'administrator_name'
              administrator_password = 'administrator_password'
              administrator_script = 'administrator_script'
              allow(Formatron::CloudFormation::Scripts).to receive(
                :windows_administrator
              ).with(
                name: administrator_name,
                password: administrator_password
              ) { administrator_script }
              expect(
                EC2.instance(
                  instance_profile: instance_profile,
                  availability_zone: availability_zone,
                  instance_type: instance_type,
                  key_name: key_name,
                  administrator_name: administrator_name,
                  administrator_password: administrator_password,
                  subnet: subnet,
                  name: name,
                  wait_condition_handle: wait_condition_handle,
                  security_group: security_group,
                  logical_id: logical_id,
                  source_dest_check: source_dest_check,
                  os: os
                )
              ).to eql(
                Type: 'AWS::EC2::Instance',
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
                      os
                    ]
                  },
                  SourceDestCheck: source_dest_check,
                  InstanceType: instance_type,
                  KeyName: key_name,
                  SubnetId: { Ref: subnet },
                  SecurityGroupIds: [{ Ref: security_group }],
                  Tags: [{
                    Key: 'Name',
                    Value: name
                  }],
                  UserData: {
                    'Fn::Base64' => {
                      'Fn::Join' => [
                        '', [
                          "<powershell>\n",
                          "try\n",
                          "{\n",
                          administrator_script,
                          'winrm quickconfig -q', "\n",
                          "winrm set winrm/config/winrs '@{MaxMemoryPerShellMB=\"1024\"}'", "\n",
                          "winrm set winrm/config '@{MaxTimeoutms=\"1800000\"}'", "\n",
                          "winrm set winrm/config/service '@{AllowUnencrypted=\"true\"}'", "\n",
                          "winrm set winrm/config/service/auth '@{Basic=\"true\"}'", "\n",
                          'netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow', "\n",
                          'netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow', "\n",
                          'Stop-Service winrm', "\n",
                          'Set-Service winrm -startuptype "automatic"', "\n",
                          'Start-Service winrm', "\n",
                          'cfn-init.exe -v -s ', { Ref: 'AWS::StackName' },
                          " -r #{logical_id}",
                          ' --region ', { Ref: 'AWS::Region' }, "\n",
                          "}\n",
                          "catch\n",
                          "{\n",
                          'cfn-signal.exe -e 1 ',
                          {
                            'Fn::Base64' => {
                              Ref: wait_condition_handle
                            }
                          }, "\n",
                          "}\n",
                          '</powershell>'
                        ]
                      ]
                    }
                  }
                }
              )
            end
            # rubocop:enable Metrics/LineLength
          end
        end
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
