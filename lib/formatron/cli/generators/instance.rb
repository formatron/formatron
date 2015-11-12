require 'formatron/generators/instance'

class Formatron
  class CLI
    module Generators
      # CLI command for instance generator
      module Instance
        # rubocop:disable Metrics/MethodLength
        def instance_options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option '-i', '--instance-name STRING', 'The name for the instance'
          c.option(
            '-s',
            '--s3-bucket STRING',
            'The S3 bucket to store encrypted configuration'
          )
          c.option(
            '-b',
            '--bootstrap-configuration STRING',
            'The name of the bootstrap configuration to depend on'
          )
          c.option(
            '-p',
            '--vpc STRING',
            'The name of the VPC to add the instance to'
          )
          c.option(
            '-u',
            '--subnet STRING',
            'The name of the subnet to add the instance to'
          )
          c.option(
            '-x',
            '--targets LIST',
            Array,
            'The targets (eg. production test)'
          )
        end
        # rubocop:enable Metrics/MethodLength

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

        def instance_instance_name(options, name)
          options.instance_name || ask('Instance Name? ') do |q|
            q.default = name
          end
        end

        def instance_s3_bucket(options)
          options.s3_bucket || ask('S3 Bucket? ')
        end

        def instance_bootstrap_configuration(options)
          options.bootstrap_configuration ||
            ask('Bootstrap configuration? ')
        end

        def instance_vpc(options)
          options.vpc || ask('VPC? ') do |q|
            q.default = 'vpc'
          end
        end

        def instance_subnet(options)
          options.subnet || ask('Subnet? ') do |q|
            q.default = 'private'
          end
        end

        def instance_targets(options)
          options.targets || ask('Targets? ', Array) do |q|
            q.default = 'production test'
          end
        end

        # rubocop:disable Metrics/MethodLength
        def instance_action(c)
          c.action do |_args, options|
            directory = instance_directory options
            name = instance_name options, directory
            Formatron::Generators::Instance.generate(
              directory,
              name: name,
              instance_name: instance_instance_name(options, name),
              s3_bucket: instance_s3_bucket(options),
              bootstrap_configuration:
                instance_bootstrap_configuration(options),
              vpc: instance_vpc(options),
              subnet: instance_subnet(options),
              targets: instance_targets(options)
            )
          end
        end
        # rubocop:enable Metrics/MethodLength

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
