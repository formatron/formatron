require_relative '../../instance'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class ChefServer < Instance
          #  Chef Server organization configuration
          class Organization
            %i(
              short_name
              full_name
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
end
