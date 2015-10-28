require_relative 'ec2/dsl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # EC2 key pair configuration
        class EC2
          attr_reader(
            :key_pair,
            :private_key
          )

          def initialize(scope, block)
            @dsl = DSL.new(
              scope,
              block
            )
            _initialize_properties
          end

          def _initialize_properties
            @key_pair = @dsl.key_pair
            @private_key = @dsl.private_key
          end

          private(
            :_initialize_properties
          )
        end
      end
    end
  end
end
