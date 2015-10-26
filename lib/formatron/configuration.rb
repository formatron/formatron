require 'formatron/configuration/config'

class Formatron
  # Processes the target specific configuration
  class Configuration
    def initialize(_aws, directory)
      @config = Config.new directory
    end

    def targets
    end

    def protected?(_target)
    end
  end
end
