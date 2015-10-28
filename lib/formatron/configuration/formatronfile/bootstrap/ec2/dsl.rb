class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class EC2
          # DSL for the bootstrap EC2 section
          class DSL
            def initialize(scope, block)
              scope.each do |key, value|
                self.class.send(:define_method, key, proc { value })
              end
              instance_eval(&block)
            end

            def key_pair(value = nil)
              @key_pair = value unless value.nil?
              @key_pair
            end

            def private_key(value = nil)
              @private_key = value unless value.nil?
              @private_key
            end
          end
        end
      end
    end
  end
end
