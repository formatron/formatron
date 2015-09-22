class Formatron
  # parses cloudformation blocks
  class Cloudformation
    attr_reader :config, :parameters

    def initialize(config, block)
      @config = config.hash
      @parameters = {}
      instance_eval(&block)
    end

    def parameter(key, value)
      @parameters[key] = value
    end
  end
end
