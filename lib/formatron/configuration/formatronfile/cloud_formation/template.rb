class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation template JSON
        # rubocop:disable Metrics/ModuleLength
        module Template
          def self.create(description)
            {
              AWSTemplateFormatVersion: '2010-09-09',
              Description: "#{description}"
            }
          end

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/AbcSize
          def self.add_vpc(template:, vpc:)
            resources = _resources template
            outputs = _outputs template
            resources[:vpc] = {
              Type: 'AWS::EC2::VPC',
              Properties: {
                CidrBlock: vpc.cidr,
                EnableDnsSupport: true,
                EnableDnsHostnames: true,
                InstanceTenancy: 'default'
              }
            }
            resources[:internetGateway] = {
              Type: 'AWS::EC2::InternetGateway'
            }
            resources[:vpcGatewayAttachment] = {
              Type: 'AWS::EC2::VPCGatewayAttachment',
              Properties: {
                InternetGatewayId: _ref('internetGateway'),
                VpcId: _ref('vpc')
              }
            }
            resources[:publicRouteTable] = {
              Type: 'AWS::EC2::RouteTable',
              Properties: {
                VpcId: _ref('vpc')
              }
            }
            resources[:publicRoute] = {
              Type: 'AWS::EC2::Route',
              DependsOn: 'vpcGatewayAttachment',
              Properties: {
                RouteTableId: _ref('publicRouteTable'),
                DestinationCidrBlock: '0.0.0.0/0',
                GatewayId: _ref('internetGateway')
              }
            }
            resources[:privateRouteTable] = {
              Type: 'AWS::EC2::RouteTable',
              Properties: {
                VpcId: _ref('vpc')
              }
            }
            resources[:privateRoute] = {
              Type: 'AWS::EC2::Route',
              Properties: {
                RouteTableId: _ref('privateRouteTable'),
                DestinationCidrBlock: '0.0.0.0/0',
                InstanceId: _ref('natInstance')
              }
            }
            outputs[:vpc] = {
              Value: _ref('vpc')
            }
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
          # rubocop:disable Metrics/AbcSize
          def self.add_subnet(template:, name:, subnet:)
            route_table =
              subnet.public? ? 'publicRouteTable' : 'privateRouteTable'
            resources = _resources template
            outputs = _outputs template
            resources["#{name}Subnet".to_sym] = {
              Type: 'AWS::EC2::Subnet',
              Properties: {
                VpcId: _ref('vpc'),
                CidrBlock: subnet.cidr,
                AvailabilityZone: subnet.availability_zone
              }
            }
            resources["#{name}SubnetRouteTableAssociation".to_sym] = {
              Type: 'AWS::EC2::SubnetRouteTableAssociation',
              Properties: {
                RouteTableId: _ref(route_table),
                SubnetId: _ref("#{name}Subnet")
              }
            }
            outputs["#{name}Subnet".to_sym] = {
              Value: _ref("#{name}Subnet")
            }
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/MethodLength

          def self._resources(template)
            template[:Resources] ||= {}
          end

          def self._outputs(template)
            template[:Outputs] ||= {}
          end

          def self._ref(logical_id)
            { Ref: logical_id }
          end

          private_class_method(
            :_resources,
            :_outputs,
            :_ref
          )
        end
        # rubocop:enable Metrics/ModuleLength
      end
    end
  end
end