require 'formatron/generators/credentials'
require 'formatron/aws'

class Formatron
  class CLI
    module Generators
      # CLI command for credentials generator
      module Credentials
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
          else
            global_credentials
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
                Credentials.default_generated_credentials(
                  credentials_directory(options)
                )
            end
        end

        def credentials_region(options)
          options.region || choose(
            'Region:',
            *Formatron::AWS::REGIONS.keys
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
            Formatron::Generators::Credentials.generate(
              credentials_credentials(options),
              credentials_region(options),
              credentials_access_key_id(options),
              credentials_secret_access_key(options)
            )
          end
        end

        def credentials_formatron_command
          command :'generate credentials' do |c|
            c.syntax = 'formatron generate credentials [options]'
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
