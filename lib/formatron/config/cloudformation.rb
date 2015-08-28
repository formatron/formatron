class Formatron
  class Config
    class Cloudformation
      attr_reader :config, :parameters

      def initialize(config, &block)
        @config = config
        @parameters = {}
        instance_eval(&block) if block_given?
      end

      def parameter(key, value)
        @parameters[key] = value
      end
    end
  end
end
