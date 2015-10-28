require 'formatron/configuration/config'
require 'formatron/configuration/formatronfile'

class Formatron
  # Processes the target specific configuration
  class Configuration
    def initialize(aws, directory)
      @aws = aws
      @directory = directory
      @formatronfiles = {}
    end

    def targets
      Config.targets @directory
    end

    def protected?(target)
      _load_formatronfile target
      @formatronfiles[target].bootstrap.protect
    end

    def name(target)
      _load_formatronfile target
      @formatronfiles[target].name
    end

    def kms_key(target)
      _load_formatronfile target
      @formatronfiles[target].bootstrap.kms_key
    end

    def bucket(target)
      _load_formatronfile target
      @formatronfiles[target].bucket
    end

    def config(target)
      _load_formatronfile target
      @config
    end

    def _load_formatronfile(target)
      @config = Config.target @directory, target
      @formatronfiles[target] ||= Formatronfile.new(
        @aws,
        target,
        @config,
        @directory
      )
    end

    private(
      :_load_formatronfile
    )
  end
end
