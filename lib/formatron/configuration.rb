module Formatron
  # deploys a configuration
  module Configuration
    # CLI command for deploy
    module DeployCLI
      def options(c)
        c.option(
          '-t',
          '--target STRING',
          'The target configuration (eg. production)'
        )
      end

      def directory(options)
        directory = options.directory || Dir.pwd
        File.expand_path directory
      end

      def credentials(options)
        credentials =
          options.credentials ||
          Generators::Credentials::CLI.default_credentials(directory)
        File.expand_path credentials
      end

      def target(options, configuration)
        options.target || choose(
          'Target?',
          configuration.targets
        )
      end

      def ok(configuration, target)
        !configuration.protected?(target) || agree(
          "Are you sure you wish to deploy protected target: #{target}?"
        )
      end

      def action(c)
        c.action do |_args, options|
          configuration = Configuration.new(
            credentials,
            directory
          )
          t = target options, configuration
          configuration.deploy(
            t
          ) if ok(configuration, t)
        end
      end

      def deploy_command
        command :deploy do |c|
          c.syntax = 'formatron deploy [options]'
          c.summary = 'Deploy or update a Formatron stack'
          c.description = 'Deploy or update a Formatron stack'
          options c
          action c
        end
      end
    end

    # CLI command for destroy
    module DestroyCLI
      def options(c)
        c.option(
          '-t',
          '--target STRING',
          'The target configuration (eg. production)'
        )
      end

      def directory(options)
        directory = options.directory || Dir.pwd
        File.expand_path directory
      end

      def credentials(options)
        credentials =
          options.credentials ||
          Generators::Credentials::CLI.default_credentials(directory(options))
        File.expand_path credentials
      end

      def target(options, configuration)
        options.target || choose(
          'Target?',
          configuration.targets
        )
      end

      def ok(configuration, target)
        !configuration.protected?(target) || agree(
          "Are you sure you wish to destroy protected target: #{target}?"
        )
      end

      def action(c)
        c.action do |_args, options|
          configuration = Configuration.new(
            credentials(options),
            directory(options)
          )
          t = target options, configuration
          configuration.destroy(
            t
          ) if ok(configuration, t)
        end
      end

      def destroy_command
        command :destroy do |c|
          c.syntax = 'formatron destroy [options]'
          c.summary = 'Destroy a Formatron stack'
          c.description = 'Destroy a Formatron stack'
          options c
          action c
        end
      end
    end

    def deploy(_target)
    end

    def destroy(_target)
    end
  end
end
