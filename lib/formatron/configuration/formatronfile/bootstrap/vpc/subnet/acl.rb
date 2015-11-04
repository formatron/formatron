class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          class Subnet
            # Subnet ACL configuration
            class ACL
              attr_reader :source_cidrs

              def source_cidr(cidr)
                @source_cidrs ||= []
                @source_cidrs.push cidr
              end
            end
          end
        end
      end
    end
  end
end
