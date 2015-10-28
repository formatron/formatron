require_relative 'bootstrap/dsl'
require_relative 'bootstrap/ec2'
require_relative 'bootstrap/vpc'

class Formatron
  class Configuration
    class Formatronfile
      # bootstrap configuration
      class Bootstrap
        attr_reader(
          :protect,
          :kms_key,
          :hosted_zone_id,
          :ec2,
          :vpc
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
          new_scope = scope.clone
          new_scope[:kms_key] = @kms_key
          new_scope[:protect] = @protect
          new_scope[:hosted_zone_id] = @hosted_zone_id
          _initialize_ec2 new_scope
          _initialize_vpc new_scope
        end

        def _initialize_ec2(scope)
          @ec2 = EC2.new(
            scope,
            @dsl.ec2
          )
        end

        def _initialize_vpc(scope)
          @vpc = VPC.new(
            scope,
            @dsl.vpc
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
