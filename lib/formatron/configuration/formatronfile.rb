require_relative 'formatronfile/dsl'
require_relative 'formatronfile/dsl/bootstrap'
require_relative 'formatronfile/bootstrap'
require_relative 'formatronfile/cloud_formation'

class Formatron
  class Configuration
    # Processes the Formatronfile in the context of the given target
    class Formatronfile
      attr_reader(
        :bootstrap,
        :cloud_formation_template,
        :name,
        :bucket
      )

      def initialize(aws, target, config, directory)
        @aws = aws
        @target = target
        @config = config
        _initialize_dsl directory
        _initialize_dsl_bootstrap
        _initialize_bootstrap
        _initialize_cloud_formation_template
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

      def _initialize_dsl_bootstrap
        @dsl_bootstrap = DSL::Bootstrap.new(
          @target,
          @config,
          @name,
          @bucket,
          @dsl.bootstrap
        )
      end

      def _initialize_bootstrap
        @bootstrap = Bootstrap.new(
          @dsl_bootstrap.protect,
          @dsl_bootstrap.kms_key
        )
      end

      def _initialize_cloud_formation_template
        @cloud_formation_template = CloudFormation.bootstrap_template
      end

      private(
        :_initialize_dsl,
        :_initialize_dsl_bootstrap,
        :_initialize_bootstrap,
        :_initialize_cloud_formation_template
      )
    end
  end
end
