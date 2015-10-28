class Formatron
  class Configuration
    class Formatronfile
      class DSL
        # DSL for the Formatronfile bootstrap section
        class Bootstrap
          attr_reader(
            :target,
            :config,
            :name,
            :bucket
          )

          def initialize(target, config, name, bucket, block)
            @target = target
            @config = config
            @name = name
            @bucket = bucket
            instance_eval(&block)
          end

          def protect(value = nil)
            @protect = value unless value.nil?
            @protect
          end

          def kms_key(value = nil)
            @kms_key = value unless value.nil?
            @kms_key
          end
        end
      end
    end
  end
end
