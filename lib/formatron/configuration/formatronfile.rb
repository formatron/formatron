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

      def initialize(aws, scope, directory)
        @aws = aws
        _initialize_dsl scope, directory
        _initialize_bootstrap scope unless @dsl.bootstrap.nil?
        @cloud_formation_template =
          CloudFormation.template self
      end

      def protected?
        @protect
      end

      def _initialize_dsl(scope, directory)
        @dsl = DSL.new(
          scope,
          File.join(directory, 'Formatronfile')
        )
        @name = @dsl.name
        @bucket = @dsl.bucket
      end

      def _initialize_bootstrap(scope)
        bootstrap_scope = scope.clone
        bootstrap_scope[:name] = @name
        bootstrap_scope[:bucket] = @bucket
        @bootstrap = Bootstrap.new(
          bootstrap_scope,
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
