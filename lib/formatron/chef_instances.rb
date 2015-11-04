require 'formatron/cloud_formation_stack'

class Formatron
  # manage the instance provisioning with Chef
  module ChefInstances
    # rubocop:disable Metrics/MethodLength
    def self.provision(aws:, configuration:, target:)
      name = configuration.name target
      CloudFormationStack.stack_ready!(
        aws: aws,
        name: configuration.name(target),
        target: target
      )
      _chef_keys = ChefKeys.new(
        aws: aws,
        bucket: configuration.bucket(target),
        name: name,
        target: target
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.destroy(aws:, configuration:, target:)
      puts aws
      puts configuration
      puts target
    end
  end
end
