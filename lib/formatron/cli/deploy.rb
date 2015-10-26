require 'formatron'

class Formatron
  class CLI
    # CLI command for deploy
    module Deploy
      def deploy_directory(options)
        options.directory || Dir.pwd
      end

      def deploy_credentials(options)
        options.credentials ||
          Generators::Credentials.default_credentials(
            deploy_directory(options)
          )
      end

      def deploy_target(target, formatron)
        target || choose(
          'Target?',
          *formatron.targets
        )
      end

      def deploy_ok(formatron, target)
        !formatron.protected?(target) || agree(
          "Are you sure you wish to deploy protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      def deploy_action(c)
        c.action do |args, options|
          formatron = Formatron.new(
            deploy_credentials(options),
            deploy_directory(options)
          )
          t = deploy_target args[0], formatron
          formatron.deploy(
            t
          ) if deploy_ok(formatron, t)
        end
      end

      def deploy_formatron_command
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
