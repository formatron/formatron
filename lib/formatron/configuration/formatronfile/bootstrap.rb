require_relative 'bootstrap/ec2'
require_relative 'bootstrap/vpc'
require_relative 'bootstrap/bastion'
require_relative 'bootstrap/nat'
require_relative 'bootstrap/chef_server'

class Formatron
  class Configuration
    class Formatronfile
      # bootstrap configuration
      class Bootstrap
        %i(
          prefix
          protect
          kms_key
          hosted_zone_id
        ).each do |symbol|
          define_method symbol do |value = nil|
            iv = "@#{symbol}"
            instance_variable_set iv, value unless value.nil?
            instance_variable_get iv
          end
        end

        {
          ec2: EC2,
          vpc: VPC,
          bastion: Bastion,
          nat: NAT,
          chef_server: ChefServer
        }.each do |symbol, cls|
          define_method symbol do |&block|
            iv = "@#{symbol}"
            instance_variable_set iv, cls.new unless instance_variable_get iv
            block.call instance_variable_get(iv) unless block.nil?
            instance_variable_get iv
          end
        end
      end
    end
  end
end
