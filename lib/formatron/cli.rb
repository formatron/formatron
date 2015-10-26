require 'commander'
require 'formatron/version'

class Formatron
  # CLI interface
  class CLI
    include Commander::Methods

    def global_options
      global_option '-c', '--credentials FILE', 'The credentials file'
      global_option(
        '-d',
        '--directory DIRECTORY',
        'The Formatron configuration directory'
      )
    end

    def commands
      self.class.instance_methods.each do |method|
        send(method) if method =~ /_formatron_command$/
      end
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
