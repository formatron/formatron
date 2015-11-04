require_relative 'chef_server/organization'
require_relative '../instance'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        #  Chef Server instance configuration
        class ChefServer < Instance
          %i(
            version
            cookbooks_bucket
            organization
            username
            email
            first_name
            last_name
            password
            ssl_key
            ssl_cert
            ssl_verify
          ).each do |symbol|
            define_method symbol do |value = nil|
              instance_variable_set "@#{symbol}", value unless value.nil?
              instance_variable_get "@#{symbol}"
            end
          end

          {
            organization: Organization
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
end
