require_relative '../configuration'

module Formatron
  class Configuration
    # CLI command for destroy
    module DestroyCLI
      def destroy_directory(options)
        directory = options.directory || Dir.pwd
        File.expand_path directory
      end

      def destroy_credentials(options)
        credentials =
          options.credentials ||
          Generators::Credentials::CLI.default_credentials(
            destroy_directory(options)
          )
        File.expand_path credentials
      end

      def destroy_target(target, configuration)
        target || choose(
          'Target?',
          *configuration.targets
        )
      end

      def destroy_ok(configuration, target)
        !configuration.protected?(target) || agree(
          "Are you sure you wish to destroy protected target: #{target}?"
        )
      end

      def destroy_action(c)
        c.action do |args, options|
          configuration = Configuration.new(
            destroy_credentials(options),
            destroy_directory(options)
          )
          t = destroy_target args[0], configuration
          configuration.destroy(
            t
          ) if destroy_ok(configuration, t)
        end
      end

      def destroy_formatron_command
        command :destroy do |c|
          c.syntax = 'formatron destroy [options] [TARGET]'
          c.summary = 'Destroy a Formatron stack'
          c.description = 'Destroy a Formatron stack'
          destroy_action c
        end
      end
    end
  end
end
