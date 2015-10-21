require_relative 'bootstrap/formatronfile'
require_relative 'bootstrap/config'
require_relative 'bootstrap/ssl'
require_relative 'bootstrap/instance_cookbook'
require_relative 'bootstrap/readme'

module Formatron
  module Generators
    # generates a bootstrap configuration
    module Bootstrap
      # CLI command for bootstrap generator
      module CLI
        def options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option(
            '-h',
            '--hosted-zone-id STRING',
            'The Route53 Hosted Zone ID for the public hosted zone'
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

        def hosted_zone_id(options)
          options.hosted_zone_id || ask('Hosted Zone ID? ')
        end

        def action(c)
          c.action do |_args, options|
            dir = directory options
            Bootstrap.generate(
              dir,
              name(options, dir),
              hosted_zone_id(options)
            )
          end
        end

        def bootstrap_command
          command :bootstrap do |c|
            c.syntax = 'formatron bootstrap [options]'
            c.summary = 'Generate a bootstrap configuration'
            c.description = 'Generate a bootstrap configuration'
            options c
            action c
          end
        end
      end

      def self.generate(directory, params)
        Readme.write directory, params[:name]
        Formatronfile.write directory, params
        Config.write directory, '_default'
        params[:targets].each do |target, _|
          Config.write directory, target
          SSL.write directory, target
        end
        InstanceCookbook.write directory
      end
    end
  end
end
