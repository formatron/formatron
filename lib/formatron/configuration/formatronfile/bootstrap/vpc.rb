require_relative 'vpc/dsl'
require_relative 'vpc/subnet'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # VPC configuration
        class VPC
          attr_reader(
            :cidr,
            :subnets
          )

          def initialize(scope, block)
            @dsl = DSL.new(
              scope,
              block
            )
            _initialize_properties scope
          end

          def _initialize_properties(scope)
            @cidr = @dsl.cidr
            _initialize_subnets scope
          end

          def _initialize_subnets(scope)
            @subnets = {}
            subnet_scope = scope.clone
            subnet_scope[:vpc_cidr] = @cidr
            @dsl.subnets.each do |key, subnet|
              subnet_scope[:subnet_name] = key
              @subnets[key] = Subnet.new(
                subnet_scope,
                subnet
              )
            end
          end

          private(
            :_initialize_properties,
            :_initialize_subnets
          )
        end
      end
    end
  end
end
