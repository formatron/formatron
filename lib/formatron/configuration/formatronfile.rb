require_relative 'formatronfile/dsl'

class Formatron
  class Configuration
    # Processes the Formatronfile in the context of the given target
    class Formatronfile
      attr_reader(
        :target,
        :name,
        :bucket,
        :kms_key,
        :bootstrap
      )

      def initialize(aws:, config:, target:, directory:)
        @target = target
        _initialize_dsl(
          aws: aws,
          config: config,
          target: target,
          directory: directory
        )
        _initialize_bootstrap unless @dsl.bootstrap.nil?
      end

      def protected?
        @protect
      end

      def _initialize_dsl(aws:, config:, target:, directory:)
        @dsl = DSL.new(
          aws: aws,
          config: config,
          target: target,
          file: File.join(directory, 'Formatronfile')
        )
        @name = @dsl.name
        @bucket = @dsl.bucket
      end

      def _initialize_bootstrap
        @bootstrap = @dsl.bootstrap
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
