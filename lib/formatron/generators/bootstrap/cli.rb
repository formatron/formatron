require_relative '../bootstrap'

module Formatron
  module Generators
    module Bootstrap
      # CLI command for bootstrap generator
      module CLI
        def bootstrap_options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option(
            '-z',
            '--hosted-zone-id STRING',
            'The Route53 Hosted Zone ID for the public hosted zone'
          )
        end

        def bootstrap_directory(options)
          directory = options.directory || ask('Directory? ') do |q|
            q.default = Dir.pwd
          end
          File.expand_path directory
        end

        def bootstrap_name(options, directory)
          options.name || ask('Name? ') do |q|
            q.default = File.basename directory
          end
        end

        def bootstrap_hosted_zone_id(options)
          options.hosted_zone_id || ask('Hosted Zone ID? ')
        end

        def bootstrap_action(c)
          c.action do |_args, options|
            directory = bootstrap_directory options
            Bootstrap.generate(
              directory,
              bootstrap_name(options, directory),
              bootstrap_hosted_zone_id(options)
            )
          end
        end

        def bootstrap_command
          command :bootstrap do |c|
            c.syntax = 'formatron bootstrap [options]'
            c.summary = 'Generate a bootstrap configuration'
            c.description = 'Generate a bootstrap configuration'
            bootstrap_options c
            bootstrap_action c
          end
        end
      end
    end
  end
end
