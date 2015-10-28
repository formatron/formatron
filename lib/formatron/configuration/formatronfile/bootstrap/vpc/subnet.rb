require_relative 'subnet/dsl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          # Subnet configuration
          class Subnet
            attr_reader(
              :availability_zone,
              :cidr,
              :source_ips
            )

            def initialize(scope, block)
              @dsl = DSL.new(
                scope,
                block
              )
              _initialize_properties
            end

            def _initialize_properties
              @availability_zone = @dsl.availability_zone
              @cidr = @dsl.cidr
              @source_ips = @dsl.source_ips
            end

            private(
              :_initialize_properties
            )
          end
        end
      end
    end
  end
end
