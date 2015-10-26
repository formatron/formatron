require 'formatron/generators/bootstrap'

class Formatron
  class CLI
    module Generators
      # CLI command for bootstrap generator
      # rubocop:disable Metrics/ModuleLength
      module Bootstrap
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
            '--ec2-key-pair STRING',
            'The EC2 key pair to associate with EC2 instances'
          )
          c.option(
            '-z',
            '--hosted-zone-id STRING',
            'The Route53 Hosted Zone ID for the public hosted zone'
          )
          c.option(
            '-a',
            '--availability-zone STRING',
            'The AWS availability zone letter (region is already taken ' \
            'from the AWS credentials)'
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
            '-p',
            '--password STRING',
            'The password for the Chef Server user'
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
            '-x',
            '--protected-targets LIST',
            Array,
            'The protected targets (eg. production)'
          )
          c.option(
            '-y',
            '--unprotected-targets LIST',
            Array,
            'The unprotected targets (eg. test)'
          )
        end
        # rubocop:enable Metrics/MethodLength

        def bootstrap_directory(options)
          options.directory || ask('Directory? ') do |q|
            q.default = Dir.pwd
          end
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

        def bootstrap_ec2_key_pair(options)
          options.ec2_key_pair || ask('EC2 Key Pair? ')
        end

        def bootstrap_hosted_zone_id(options)
          options.hosted_zone_id || ask('Hosted Zone ID? ')
        end

        def bootstrap_availability_zone(options)
          options.availability_zone || ask('Availability Zone? ')
        end

        def bootstrap_organization(options)
          options.organization || ask('Chef Server Organization? ')
        end

        def bootstrap_username(options)
          options.username || ask('Chef Server Username? ')
        end

        def bootstrap_password(options)
          options.password || password('Chef Server Password? ')
        end

        def bootstrap_email(options)
          options.email || ask('Chef Server User Email? ')
        end

        def bootstrap_first_name(options)
          options.first_name || ask('Chef Server User First Name? ')
        end

        def bootstrap_last_name(options)
          options.last_name || ask('Chef Server User Last Name? ')
        end

        def bootstrap_protected_targets(options)
          options.protected_targets || ask('Protected Targets? ', Array) do |q|
            q.default = 'production'
          end
        end

        def bootstrap_unprotected_targets(options)
          options.unprotected_targets ||
            ask('Unprotected Targets? ', Array) do |q|
              q.default = 'test'
            end
        end

        def bootstrap_targets(options)
          protected_targets = bootstrap_protected_targets options
          unprotected_targets = bootstrap_unprotected_targets options
          targets = {}
          protected_targets.each do |target|
            targets[target.to_sym] = { protect: true }
          end
          unprotected_targets.each do |target|
            targets[target.to_sym] = { protect: false }
          end
          targets
        end

        # rubocop:disable Metrics/MethodLength
        def bootstrap_params(options, directory)
          {
            name: bootstrap_name(options, directory),
            s3_bucket: bootstrap_s3_bucket(options),
            kms_key: bootstrap_kms_key(options),
            ec2_key_pair: bootstrap_ec2_key_pair(options),
            hosted_zone_id: bootstrap_hosted_zone_id(options),
            availability_zone: bootstrap_availability_zone(options),
            chef_server: {
              organization: bootstrap_organization(options),
              username: bootstrap_username(options),
              password: bootstrap_password(options),
              email: bootstrap_email(options),
              first_name: bootstrap_first_name(options),
              last_name: bootstrap_last_name(options)
            },
            targets: bootstrap_targets(options)
          }
        end
        # rubocop:enable Metrics/MethodLength

        def bootstrap_action(c)
          c.action do |_args, options|
            directory = bootstrap_directory options
            Formatron::Generators::Bootstrap.generate(
              directory,
              bootstrap_params(options, directory)
            )
          end
        end

        def bootstrap_formatron_command
          command :'generate bootstrap' do |c|
            c.syntax = 'formatron generate bootstrap [options]'
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
