require_relative 'subnet/nat'
require_relative 'subnet/bastion'
require_relative 'subnet/chef_server'
require_relative 'subnet/instance'
require_relative '../vpc'
require 'formatron/cloud_formation/template/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # generates CloudFormation subnet resources
        class Subnet
          PREFIX = 'subnet'

          def initialize(subnet:)
            @subnet = subnet
            @vpc = subnet.dsl_parent
            @subnet_id = "#{PREFIX}#{@subnet.guid}"
            @vpc_id = "#{VPC::PREFIX}#{@vpc.guid}"
            @gateway = @subnet.gateway
            @availability_zone = @subnet.availability_zone
            @cidr = @subnet.cidr
          end

          # rubocop:disable Metrics/MethodLength
          def merge(resources:, outputs:)
            {
              nat: NAT,
              bastion: Bastion,
              chef_server: ChefServer,
              instance: Instance
            }.each do |symbol, cls|
              @subnet.send(symbol).each do |_, instance|
                instance = cls.new symbol => instance
                instance.merge resources: resources, outputs: outputs
              end
            end
            _add_subnet resources, outputs
          end
          # rubocop:enable Metrics/MethodLength

          def _add_subnet(resources, outputs)
            resources[@subnet_id] = Resources::EC2.subnet(
              vpc: @vpc_id,
              cidr: @cidr,
              availability_zone: @availability_zone,
              map_public_ip_on_launch: @gateway.nil?
            )
            outputs[@subnet_id] = Template.output Template.ref(@subnet_id)
          end

          private(
            :_add_subnet
          )
        end
      end
    end
  end
end
