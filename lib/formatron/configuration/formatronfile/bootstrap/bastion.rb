class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # Bastion instance configuration
        class Bastion
          def subnet(value = nil)
            @subnet = value unless value.nil?
            @subnet
          end

          def sub_domain(value = nil)
            @sub_domain = value unless value.nil?
            @sub_domain
          end

          def instance_cookbook(value = nil)
            @instance_cookbook = value unless value.nil?
            @instance_cookbook
          end
        end
      end
    end
  end
end
