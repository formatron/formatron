module Formatron
  module Generators
    # generates a credentials JSON file
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

        def options(c)
          c.option '-r', '--region STRING', 'The AWS region'
          c.option '-a', '--access-key-id STRING', 'The AWS access key ID'
          c.option(
            '-s',
            '--secret-access-key STRING',
            'The AWS secret access key'
          )
        end

        def directory(options)
          directory = options.directory || Dir.pwd
          File.expand_path directory
        end

        def credentials(options)
          credentials =
            options.credentials ||
            ask('Credentials file? ') do |q|
              q.default = CLI.default_generated_credentials directory(options)
            end
          File.expand_path credentials
        end

        def region(options)
          options.region || choose(
            'Region:',
            REGIONS
          )
        end

        def access_key_id(options)
          options.access_key_id || ask('Access Key ID? ')
        end

        def secret_access_key(options)
          options.secret_access_key || password('Secret Access Key? ')
        end

        def action(c)
          c.action do |_args, options|
            Credentials.generate(
              credentials(options),
              region(options),
              access_key_id(options),
              secret_access_key(options)
            )
          end
        end

        def credentials_command
          command :credentials do |c|
            c.syntax = 'formatron credentials [options]'
            c.summary = 'Generate a credentials JSON file'
            c.description = 'Generate a credentials JSON file'
            options c
            action c
          end
        end
      end

      def self.generate(file, region, access_key_id, secret_access_key)
        FileUtils.mkdir_p File.dirname(file)
        File.write file, <<-EOH.gsub(/^ {10}/, '')
          {
            "region": "#{region}",
            "access_key_id": "#{access_key_id}",
            "secret_access_key": "#{secret_access_key}"
          }
        EOH
      end
    end
  end
end
