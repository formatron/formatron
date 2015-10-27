require 'formatron/configuration/config'
require 'formatron/configuration/formatronfile'

class Formatron
  # Processes the target specific configuration
  class Configuration
    def initialize(aws, directory)
      @formatronfiles = {}
      Config.targets(directory).each do |target|
        @formatronfiles[target] = Formatronfile.new(
          aws,
          target,
          Config.target(directory, target),
          directory
        )
      end
    end

    def targets
      @formatronfiles.keys
    end

    def protected?(target)
      @formatronfiles[target].bootstrap.protect
    end

    def name(_target)
    end

    def kms_key(_target)
    end

    def bucket(_target)
    end

    def config(_target)
    end
  end
end
