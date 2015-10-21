module Formatron
  # deploys a configuration
  class Configuration
    def initialize(_credentials, _directory)
    end

    def targets
      # :nocov:
      %w(production test)
      # :nocov:
    end

    def protected?(_target)
      # :nocov:
      true
      # :nocov:
    end

    def deploy(_target)
    end

    def destroy(_target)
    end
  end
end
