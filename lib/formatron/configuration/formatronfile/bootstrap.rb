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

        def initialize(scope, block)
          @dsl = DSL.new(
            scope,
            block
          )
          _initialize_properties scope
        end

        def _initialize_properties(scope)
          @protect = @dsl.protect
          @kms_key = @dsl.kms_key
          @hosted_zone_id = @dsl.hosted_zone_id
          _initialize_ec2 scope
        end

        def _initialize_ec2(scope)
          ec2_scope = scope.clone
          ec2_scope[:kms_key] = @kms_key
          ec2_scope[:protect] = @protect
          ec2_scope[:hosted_zone_id] = @hosted_zone_id
          @ec2 = EC2.new(
            ec2_scope,
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
