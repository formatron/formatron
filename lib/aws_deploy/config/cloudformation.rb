class AwsDeploy
  class Config
    class Cloudformation
      attr_reader :config, :parameters

      def initialize (config, &block)
        @config = config
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
