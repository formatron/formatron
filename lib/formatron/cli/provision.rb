require 'formatron'
require 'formatron/config'

class Formatron
  class CLI
    # CLI command for provision
    module Provision
      def provision_options(c)
        c.option(
          '-g',
          '--guid STRING',
          'The guid of an instance to provision ' \
          '(will provision all instances if not specified)'
        )
      end

      def provision_directory(options)
        options.directory || Dir.pwd
      end

      def provision_credentials(options)
        options.credentials ||
          Generators::Credentials.default_credentials(
            deploy_directory(options)
          )
      end

      def provision_target(target, directory)
        target || choose(
          'Target?',
          *Config.targets(directory: directory)
        )
      end

      def provision_ok(options, formatron, target)
        options.yes || !formatron.protected? || agree(
          "Are you sure you wish to provision protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      # rubocop:disable Metrics/MethodLength
      def provision_action(c)
        c.action do |args, options|
          directory = provision_directory options
          target = provision_target args[0], directory
          formatron = Formatron.new(
            credentials: provision_credentials(options),
            directory: directory,
            target: target
          )
          formatron.provision(
            guid: options.guid
          ) if provision_ok options, formatron, target
        end
      end
      # rubocop:enable Metrics/MethodLength

      def provision_formatron_command
        command :provision do |c|
          c.syntax = 'formatron provision [options] [TARGET]'
          c.summary = 'Provision the instances in a Formatron ' \
                      'stack using Opscode Chef'
          c.description = 'Provision the instances in a Formatron ' \
                          'stack using Opscode Chef'
          provision_options c
          provision_action c
        end
      end
    end
  end
end
