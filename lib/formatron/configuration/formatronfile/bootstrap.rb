require_relative 'bootstrap/dsl'

class Formatron
  class Configuration
    class Formatronfile
      # bootstrap configuration
      class Bootstrap
        attr_reader(
          :protect,
          :kms_key
        )

        def initialize(target, config, name, bucket, block)
          @dsl = DSL.new(
            target,
            config,
            name,
            bucket,
            block
          )
          _initialize_properties
        end

        def _initialize_properties
          @protect = @dsl.protect
          @kms_key = @dsl.kms_key
        end

        private(
          :_initialize_properties
        )
      end
    end
  end
end
