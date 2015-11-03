require_relative '../instance'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        #  Chef Server instance configuration
        class ChefServer < Instance
          %i(
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
        end
      end
    end
  end
end
