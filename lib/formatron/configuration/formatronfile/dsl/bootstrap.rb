class Formatron
  class Configuration
    class Formatronfile
      class DSL
        # DSL for the Formatronfile bootstrap section
        class Bootstrap
          def initialize(_target, _config, block)
            instance_eval(&block)
          end

          def protect(value = nil)
            @protect = value unless value.nil?
            @protect
          end
        end
      end
    end
  end
end
