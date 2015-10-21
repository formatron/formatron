module Formatron
  module Generators
    # generates a instance configuration
    module Instance
      # CLI command for instance generator
      module CLI
        def options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option(
            '-b',
            '--bootstrap-configuration STRING',
            'The name of the bootstrap configuration to depend on'
          )
        end

        def directory(options)
          directory = options.directory || ask('Directory? ') do |q|
            q.default = Dir.pwd
          end
          File.expand_path directory
        end

        def name(options, directory)
          options.name || ask('Name? ') do |q|
            q.default = File.basename directory
          end
        end

        def bootstrap_configuration(options)
          options.bootstrap_configuration ||
            ask('Bootstrap configuration? ')
        end

        def action(c)
          c.action do |_args, options|
            dir = directory options
            Instance.generate(
              dir,
              name(options, dir),
              bootstrap_configuration(options)
            )
          end
        end

        def instance_command
          command :instance do |c|
            c.syntax = 'formatron instance [options]'
            c.summary = 'Generate an instance configuration'
            c.description = 'Generate an instance configuration'
            options c
            action c
          end
        end
      end

      def self.generate(_directory, _params)
      end
    end
  end
end
