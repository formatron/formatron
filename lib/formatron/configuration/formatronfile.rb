require_relative 'formatronfile/dsl'
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
        :bucket,
        :kms_key
      )

      def initialize(aws, target, config, directory)
        @aws = aws
        @target = target
        @config = config
        _initialize_dsl directory
        _initialize_bootstrap unless @dsl.bootstrap.nil?
        @cloud_formation_template =
          CloudFormation.template self
      end

      def protected?
        @protect
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
        @bootstrap = Bootstrap.new(
          @target,
          @config,
          @name,
          @bucket,
          @dsl.bootstrap
        )
        _initialize_properties @bootstrap
      end

      def _initialize_properties(source)
        @kms_key = source.kms_key
        @protect = source.protect
      end

      private(
        :_initialize_dsl,
        :_initialize_bootstrap,
        :_initialize_properties
      )
    end
  end
end
