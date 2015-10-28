class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          # DSL for the bootstrap VPC section
          class DSL
            attr_reader(
              :subnets
            )

            def initialize(scope, block)
              scope.each do |key, value|
                self.class.send(:define_method, key, proc { value })
              end
              @subnets = {}
              instance_eval(&block)
            end

            def cidr(value = nil)
              @key_pair = value unless value.nil?
              @key_pair
            end

            def subnet(subnet_name, &block)
              @subnets[subnet_name] = block
            end
          end
        end
      end
    end
  end
end
