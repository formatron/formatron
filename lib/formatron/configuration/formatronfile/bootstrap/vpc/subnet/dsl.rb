class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          class Subnet
            # DSL for the VPC subnet sections
            class DSL
              attr_reader(
                :availability_zone,
                :cidr,
                :source_ips
              )

              def initialize(scope, block)
                scope.each do |key, value|
                  self.class.send(:define_method, key, proc { value })
                end
                instance_eval(&block)
              end

              def availability_zone(value = nil)
                @availability_zone = value unless value.nil?
                @availability_zone
              end

              def cidr(value = nil)
                @cidr = value unless value.nil?
                @cidr
              end

              def make_public(source_ips = [])
                @source_ips = source_ips
              end
            end
          end
        end
      end
    end
  end
end
