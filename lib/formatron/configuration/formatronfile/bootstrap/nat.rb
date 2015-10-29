class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # NAT instance configuration
        class NAT
          %i(
            subnet
            sub_domain
            instance_cookbook
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
