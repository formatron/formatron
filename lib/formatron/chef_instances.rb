class Formatron
  # manage the instance provisioning with Chef
  module ChefInstances
    def self.provision(aws:, configuration:, target:)
      puts aws
      puts configuration
      puts target
    end

    def self.destroy(aws:, configuration:, target:)
      puts aws
      puts configuration
      puts target
    end
  end
end
