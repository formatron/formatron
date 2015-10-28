require 'formatron/configuration/config'
require 'formatron/configuration/formatronfile'

class Formatron
  # Processes the target specific configuration
  class Configuration
    def initialize(aws, directory)
      @aws = aws
      @directory = directory
      @configs = {}
      @formatronfiles = {}
    end

    def targets
      Config.targets @directory
    end

    def protected?(target)
      _load target
      @formatronfiles[target].protected?
    end

    def name(target)
      _load target
      @formatronfiles[target].name
    end

    def kms_key(target)
      _load target
      @formatronfiles[target].kms_key
    end

    def bucket(target)
      _load target
      @formatronfiles[target].bucket
    end

    def config(target)
      _load target
      @configs[target]
    end

    def cloud_formation_template(target)
      _load target
      @formatronfiles[target].cloud_formation_template
    end

    def _load(target)
      @configs[target] ||= Config.target @directory, target
      scope = {
        target: target,
        config: @configs[target]
      }
      @formatronfiles[target] ||= Formatronfile.new(
        @aws,
        scope,
        @directory
      )
    end

    private(
      :_load
    )
  end
end
