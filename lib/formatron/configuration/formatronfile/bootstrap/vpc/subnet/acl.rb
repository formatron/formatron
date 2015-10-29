class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          class Subnet
            # Subnet ACL configuration
            class ACL
              attr_reader :source_ips

              def source_ip(ip)
                @source_ips ||= []
                @source_ips.push ip
              end
            end
          end
        end
      end
    end
  end
end
