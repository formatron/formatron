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
      @cloud_formation_templates = {}
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

    def prefix(target)
      _load target
      @formatronfiles[target].prefix
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
      _load_config target
      _load_formatronfile target
    end

    def _load_config(target)
      @configs[target] ||= Config.target(
        directory: @directory,
        target: target
      )
    end

    def _load_formatronfile(target)
      @formatronfiles[target] ||= Formatronfile.new(
        aws: @aws,
        config: @configs[target],
        target: target,
        directory: @directory
      )
    end

    private(
      :_load,
      :_load_config,
      :_load_formatronfile
    )
  end
end
