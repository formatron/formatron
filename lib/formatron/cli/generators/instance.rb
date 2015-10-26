require 'formatron/generators/instance'

class Formatron
  class CLI
    module Generators
      # CLI command for instance generator
      module Instance
        def instance_options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option(
            '-b',
            '--bootstrap-configuration STRING',
            'The name of the bootstrap configuration to depend on'
          )
        end

        def instance_directory(options)
          options.directory || ask('Directory? ') do |q|
            q.default = Dir.pwd
          end
        end

        def instance_name(options, directory)
          options.name || ask('Name? ') do |q|
            q.default = File.basename directory
          end
        end

        def instance_bootstrap_configuration(options)
          options.bootstrap_configuration ||
            ask('Bootstrap configuration? ')
        end

        def instance_action(c)
          c.action do |_args, options|
            directory = instance_directory options
            Formatron::Generators::Instance.generate(
              directory,
              name: instance_name(options, directory),
              bootstrap_configuration: instance_bootstrap_configuration(options)
            )
          end
        end

        def instance_formatron_command
          command :'generate instance' do |c|
            c.syntax = 'formatron generate instance [options]'
            c.summary = 'Generate an instance configuration'
            c.description = 'Generate an instance configuration'
            instance_options c
            instance_action c
          end
        end
      end
    end
  end
end
