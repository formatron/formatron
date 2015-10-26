require 'formatron'

class Formatron
  class CLI
    # CLI command for destroy
    module Destroy
      def destroy_directory(options)
        options.directory || Dir.pwd
      end

      def destroy_credentials(options)
        options.credentials ||
          Generators::Credentials.default_credentials(
            destroy_directory(options)
          )
      end

      def destroy_target(target, formatron)
        target || choose(
          'Target?',
          *formatron.targets
        )
      end

      def destroy_ok(formatron, target)
        !formatron.protected?(target) || agree(
          "Are you sure you wish to destroy protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      def destroy_action(c)
        c.action do |args, options|
          formatron = Formatron.new(
            destroy_credentials(options),
            destroy_directory(options)
          )
          t = destroy_target args[0], formatron
          formatron.destroy(
            t
          ) if destroy_ok(formatron, t)
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
