require_relative '../bootstrap'

module Formatron
  module Generators
    module Bootstrap
      # CLI command for bootstrap generator
      # rubocop:disable Metrics/ModuleLength
      module CLI
        # rubocop:disable Metrics/MethodLength
        def bootstrap_options(c)
          c.option '-n', '--name STRING', 'The name for the configuration'
          c.option(
            '-s',
            '--s3-bucket STRING',
            'The S3 bucket to store encrypted configuration'
          )
          c.option(
            '-k',
            '--kms-key STRING',
            'The KMS key to use for encryption'
          )
          c.option(
            '-e',
            '--ec2-key STRING',
            'The EC2 key pair to associate with EC2 instances'
          )
          c.option(
            '-z',
            '--hosted-zone-id STRING',
            'The Route53 Hosted Zone ID for the public hosted zone'
          )
          c.option(
            '-o',
            '--organization STRING',
            'The organization to create on the Chef Server'
          )
          c.option(
            '-u',
            '--username STRING',
            'The username to create on the Chef Server'
          )
          c.option(
            '-m',
            '--email STRING',
            'The email address for the Chef Server user'
          )
          c.option(
            '-f',
            '--first-name STRING',
            'The first name of the Chef Server user'
          )
          c.option(
            '-l',
            '--last-name STRING',
            'The last name of the Chef Server user'
          )
          c.option(
            '-i',
            '--instance-cookbook STRING',
            'The instance cookbook to apply additional ' \
            'configuration to the Chef Server'
          )
          c.option(
            '-j',
            '--targets-json JSON',
            'The target specific configuration for the Chef Server'
          )
        end
        # rubocop:enable Metrics/MethodLength

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

        def bootstrap_s3_bucket(options)
          options.s3_bucket || ask('S3 Bucket? ')
        end

        def bootstrap_kms_key(options)
          options.kms_key || ask('KMS Key? ')
        end

        def bootstrap_ec2_key(options)
          options.ec2_key || ask('EC2 Key? ')
        end

        def bootstrap_hosted_zone_id(options)
          options.hosted_zone_id || ask('Hosted Zone ID? ')
        end

        def bootstrap_organization(options)
          options.organization || ask('Organization? ')
        end

        def bootstrap_username(options)
          options.username || ask('Username? ')
        end

        def bootstrap_email(options)
          options.email || ask('Email? ')
        end

        def bootstrap_first_name(options)
          options.first_name || ask('First Name? ')
        end

        def bootstrap_last_name(options)
          options.last_name || ask('Last Name? ')
        end

        def bootstrap_instance_cookbook(options)
          options.instance_cookbook || ask('Instance Cookbook? ')
        end

        def bootstrap_ask_targets
          params = {}
          targets = ask 'Targets? ', Array
          targets.each do |target|
            params[target] = {}
            params[target][:protected] = agree "#{target} protected? "
            params[target][:sub_domain] = ask "#{target} sub domain? "
            params[target][:password] = password "#{target} password? "
          end
          params
        end

        def bootstrap_targets(options)
          json = options.targets_json
          json ? JSON.parse(json.gsub!(/\A'|'\Z/, '')) : bootstrap_ask_targets
        end

        # rubocop:disable Metrics/MethodLength
        def bootstrap_params(options, directory)
          {
            name: bootstrap_name(options, directory),
            s3_bucket: bootstrap_s3_bucket(options),
            kms_key: bootstrap_kms_key(options),
            ec2_key: bootstrap_ec2_key(options),
            hosted_zone_id: bootstrap_hosted_zone_id(options),
            organization: bootstrap_organization(options),
            username: bootstrap_username(options),
            email: bootstrap_email(options),
            first_name: bootstrap_first_name(options),
            last_name: bootstrap_last_name(options),
            instance_cookbook: bootstrap_instance_cookbook(options),
            targets: bootstrap_targets(options)
          }
        end
        # rubocop:enable Metrics/MethodLength

        def bootstrap_action(c)
          c.action do |_args, options|
            directory = bootstrap_directory options
            Bootstrap.generate(
              directory,
              bootstrap_params(options, directory)
            )
          end
        end

        def bootstrap_formatron_command
          command :bootstrap do |c|
            c.syntax = 'formatron bootstrap [options]'
            c.summary = 'Generate a bootstrap configuration'
            c.description = 'Generate a bootstrap configuration'
            bootstrap_options c
            bootstrap_action c
          end
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
