require 'formatron'

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

      def provision_target(target, formatron)
        target || choose(
          'Target?',
          *formatron.targets
        )
      end

      def provision_ok(formatron, target)
        !formatron.protected?(target) || agree(
          "Are you sure you wish to provision protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      def provision_action(c)
        c.action do |args, options|
          formatron = Formatron.new(
            provision_credentials(options),
            provision_directory(options)
          )
          t = provision_target args[0], formatron
          formatron.provision(
            t
          ) if provision_ok(formatron, t)
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
