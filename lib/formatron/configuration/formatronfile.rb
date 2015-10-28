require_relative 'formatronfile/dsl'
require_relative 'formatronfile/dsl/bootstrap'
require_relative 'formatronfile/bootstrap'

class Formatron
  class Configuration
    # Processes the Formatronfile in the context of the given target
    class Formatronfile
      attr_reader(
        :bootstrap,
        :name,
        :bucket
      )

      def initialize(aws, target, config, directory)
        @aws = aws
        @target = target
        @config = config
        _initialize_dsl directory
        _initialize_bootstrap
      end

      def _initialize_dsl(directory)
        @dsl = DSL.new(
          @target,
          @config,
          File.join(directory, 'Formatronfile')
        )
        @name = @dsl.name
        @bucket = @dsl.bucket
      end

      def _initialize_bootstrap
        dsl_bootstrap = _dsl_bootstrap
        @bootstrap = Bootstrap.new(
          dsl_bootstrap.protect,
          dsl_bootstrap.kms_key
        )
      end

      def _dsl_bootstrap
        DSL::Bootstrap.new(
          @target,
          @config,
          @name,
          @bucket,
          @dsl.bootstrap
        )
      end

      private(
        :_initialize_dsl,
        :_initialize_bootstrap,
        :_dsl_bootstrap
      )
    end
  end
end
