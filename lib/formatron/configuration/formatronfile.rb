require_relative 'formatronfile/dsl'
require_relative 'formatronfile/dsl/bootstrap'
require_relative 'formatronfile/bootstrap'

class Formatron
  class Configuration
    # Processes the Formatronfile in the context of the given target
    class Formatronfile
      attr_reader(
        :bootstrap
      )

      def initialize(aws, target, config, directory)
        @aws = aws
        @target = target
        @config = config
        _initialize_dsl directory
        _initialize_bootstrap
      end

      def _initialize_dsl(directory)
        @dsl = Formatron::DSL.new(
          @target,
          @config,
          File.join(directory, 'Formatronfile')
        )
      end

      def _initialize_bootstrap
        dsl_bootstrap = Formatron::DSL::Bootstrap.new(
          @target,
          @config,
          @dsl.bootstrap
        )
        @bootstrap = Bootstrap.new(
          dsl_bootstrap.protect
        )
      end

      private(
        :_initialize_dsl,
        :_initialize_bootstrap
      )
    end
  end
end
