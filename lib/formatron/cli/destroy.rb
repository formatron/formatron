require 'formatron'
require 'formatron/config'

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

      def destroy_target(target, directory)
        target || choose(
          'Target?',
          *Config.targets(directory: directory)
        )
      end

      def destroy_ok(formatron, target)
        !formatron.protected? || agree(
          "Are you sure you wish to destroy protected target: #{target}?"
        ) do |q|
          q.default = 'no'
        end
      end

      def destroy_action(c)
        c.action do |args, options|
          directory = destroy_directory options
          target = destroy_target args[0], directory
          formatron = Formatron.new(
            credentials: destroy_credentials(options),
            directory: directory,
            target: target
          )
          formatron.destroy if destroy_ok formatron, target
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
