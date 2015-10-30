require_relative 'subnet/acl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          # Subnet configuration
          class Subnet
            attr_reader(
              :acl
            )

            def availability_zone(value = nil)
              @availability_zone = value unless value.nil?
              @availability_zone
            end

            def cidr(value = nil)
              @cidr = value unless value.nil?
              @cidr
            end

            def public(value)
              if value
                @acl = ACL.new
                yield @acl if block_given?
              else
                @acl = nil
              end
            end

            def public?
              !@acl.nil?
            end
          end
        end
      end
    end
  end
end
