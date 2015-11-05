require 'formatron'
require 'formatron/config'

class Formatron
  class CLI
    # CLI command for provision
    module Provision
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

      def provision_ok(formatron, target)
        !formatron.protected? || agree(
          "Are you sure you wish to provision protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      def provision_action(c)
        c.action do |args, options|
          directory = provision_directory options
          target = provision_target args[0], directory
          formatron = Formatron.new(
            credentials: provision_credentials(options),
            directory: directory,
            target: target
          )
          formatron.provision if provision_ok formatron, target
        end
      end

      def provision_formatron_command
        command :provision do |c|
          c.syntax = 'formatron provision [options] [TARGET]'
          c.summary = 'Provision the instances in a Formatron ' \
                      'stack using Opscode Chef'
          c.description = 'Provision the instances in a Formatron ' \
                          'stack using Opscode Chef'
          provision_action c
        end
      end
    end
  end
end
