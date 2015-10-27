require 'formatron/configuration/config'
require 'formatron/configuration/formatronfile'

class Formatron
  # Processes the target specific configuration
  class Configuration
    def initialize(aws, directory)
      @aws = aws
      @directory = directory
      @formatronfile = nil
    end

    def targets
      Config.targets @directory
    end

    def protected?(target)
      _load_formatronfile target
      @formatronfile.bootstrap.protect
    end

    def _load_formatronfile(target)
      @formatronfile ||= Formatronfile.new(
        @aws,
        target,
        Config.target(@directory, target),
        @directory
      )
    end

    private(
      :_load_formatronfile
    )
  end
end
