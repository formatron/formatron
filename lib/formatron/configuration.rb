module Formatron
  # deploys a configuration
  class Configuration
    def initialize(_credentials, _directory)
    end

    def targets
      %w(production test)
    end

    def protected?(_target)
      true
    end

    def deploy(_target)
    end

    def destroy(_target)
    end
  end
end
