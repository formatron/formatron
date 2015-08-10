class AwsDeploy
  class Config
    class Cloudformation
      attr_reader :config, :parameters, :dependencies

      def initialize (config, dependencies, &block)
        @config = config
        @dependencies = dependencies
        @parameters = {}
        if block_given?
          instance_eval(&block)
        end
      end

      def parameter (key, value)
        @parameters[key] = value
      end

    end
  end
end
