require_relative '../configuration'

module Formatron
  class Configuration
    # CLI command for deploy
    module DeployCLI
      def deploy_directory(options)
        directory = options.directory || Dir.pwd
        File.expand_path directory
      end

      def deploy_credentials(options)
        credentials =
          options.credentials ||
          Generators::Credentials::CLI.default_credentials(
            deploy_directory(options)
          )
        File.expand_path credentials
      end

      def deploy_target(target, configuration)
        target || choose(
          'Target?',
          *configuration.targets
        )
      end

      def deploy_ok(configuration, target)
        !configuration.protected?(target) || agree(
          "Are you sure you wish to deploy protected target: #{target}?"
        )
      end

      def deploy_action(c)
        c.action do |args, options|
          configuration = Configuration.new(
            deploy_credentials(options),
            deploy_directory(options)
          )
          t = deploy_target args[0], configuration
          configuration.deploy(
            t
          ) if deploy_ok(configuration, t)
        end
      end

      def deploy_command
        command :deploy do |c|
          c.syntax = 'formatron deploy [options] [TARGET]'
          c.summary = 'Deploy or update a Formatron stack'
          c.description = 'Deploy or update a Formatron stack'
          deploy_action c
        end
      end
    end
  end
end
