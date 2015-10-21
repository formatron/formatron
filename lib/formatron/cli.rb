require 'commander'

require 'formatron/version'
require 'formatron/generators/credentials'
require 'formatron/generators/bootstrap'
require 'formatron/generators/instance'
require 'formatron/configuration'

module Formatron
  # CLI interface
  class CLI
    include Commander::Methods
    include Generators::Credentials::CLI
    include Generators::Bootstrap::CLI
    include Generators::Instance::CLI
    include Configuration::DeployCLI
    include Configuration::DestroyCLI

    def global_options
      global_option '-c', '--credentials FILE', 'The credentials file'
      global_option(
        '-d',
        '--directory DIRECTORY',
        'The Formatron configuration directory'
      )
    end

    def commands
      deploy_command
      destroy_command
      bootstrap_command
      instance_command
      credentials_command
    end

    def run
      program :version, Formatron::VERSION
      program :description, 'Quickly deploy AWS CloudFormation ' \
                            'stacks backed by a Chef Server'
      global_options
      commands
      run!
    end
  end
end
