class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # DSL for the Formatronfile bootstrap section
        class DSL
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

          def hosted_zone_id(value = nil)
            @hosted_zone_id = value unless value.nil?
            @hosted_zone_id
          end

          def ec2(&block)
            @ec2 = block if block_given?
            @ec2
          end
        end
      end
    end
  end
end
