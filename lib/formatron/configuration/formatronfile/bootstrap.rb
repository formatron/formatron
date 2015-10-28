require_relative 'bootstrap/dsl'
require_relative 'bootstrap/ec2'

class Formatron
  class Configuration
    class Formatronfile
      # bootstrap configuration
      class Bootstrap
        attr_reader(
          :protect,
          :kms_key,
          :hosted_zone_id,
          :ec2
        )

        def initialize(target, config, name, bucket, block)
          @dsl = DSL.new(
            target,
            config,
            name,
            bucket,
            block
          )
          _initialize_properties target, config, name, bucket
        end

        def _initialize_properties(target, config, name, bucket)
          @protect = @dsl.protect
          @kms_key = @dsl.kms_key
          @hosted_zone_id = @dsl.hosted_zone_id
          _initialize_ec2 target, config, name, bucket
        end

        def _initialize_ec2(target, config, name, bucket)
          @ec2 = EC2.new(
            target,
            config,
            name,
            bucket,
            @kms_key,
            @protect,
            @hosted_zone_id,
            @dsl.ec2
          )
        end

        private(
          :_initialize_properties,
          :_initialize_ec2
        )
      end
    end
  end
end
