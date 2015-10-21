require_relative '../credentials'

module Formatron
  module Generators
    module Credentials
      # CLI command for credentials generator
      module CLI
        REGIONS = %w(
          us-east-1
          us-west-2
          us-west-1
          eu-west-1
          eu-central-1
          ap-southeast-1
          ap-southeast-2
          ap-northeast-1
          sa-east-1
        )

        def self.dot_credentials
          File.join '.formatron', 'credentials.json'
        end

        def self.global_credentials
          File.join Dir.home, dot_credentials
        end

        def self.local_credentials(directory)
          File.join directory, dot_credentials
        end

        def self.default_credentials(directory)
          local = local_credentials directory
          if File.file?(local)
            local
          elsif File.file?(global_credentials)
            global_credentials
          else
            fail 'No credentials found'
          end
        end

        def self.default_generated_credentials(directory)
          if File.file?(File.join(directory, 'Formatronfile'))
            local_credentials(directory)
          else
            global_credentials
          end
        end

        def credentials_options(c)
          c.option '-r', '--region STRING', 'The AWS region'
          c.option '-a', '--access-key-id STRING', 'The AWS access key ID'
          c.option(
            '-s',
            '--secret-access-key STRING',
            'The AWS secret access key'
          )
        end

        def credentials_directory(options)
          options.directory || Dir.pwd
        end

        def credentials_credentials(options)
          options.credentials ||
            ask('Credentials file? ') do |q|
              q.default =
                CLI.default_generated_credentials credentials_directory(options)
            end
        end

        def credentials_region(options)
          options.region || choose(
            'Region:',
            *REGIONS
          )
        end

        def credentials_access_key_id(options)
          options.access_key_id || ask('Access Key ID? ')
        end

        def credentials_secret_access_key(options)
          options.secret_access_key || password('Secret Access Key? ')
        end

        def credentials_action(c)
          c.action do |_args, options|
            Credentials.generate(
              credentials_credentials(options),
              credentials_region(options),
              credentials_access_key_id(options),
              credentials_secret_access_key(options)
            )
          end
        end

        def credentials_formatron_command
          command :credentials do |c|
            c.syntax = 'formatron credentials [options]'
            c.summary = 'Generate a credentials JSON file'
            c.description = 'Generate a credentials JSON file'
            credentials_options c
            credentials_action c
          end
        end
      end
    end
  end
end
