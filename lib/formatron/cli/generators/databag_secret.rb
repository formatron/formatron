require 'formatron/generators/util'

class Formatron
  class CLI
    module Generators
      # CLI command for databag secret generator
      module DatabagSecret
        def databag_secret_action(c)
          c.action do |_args, _options|
            puts Formatron::Generators::Util.databag_secret
          end
        end

        def databag_secret_formatron_command
          command :'generate data bag secret' do |c|
            c.syntax = 'formatron generate data bag secret [options]'
            c.summary = 'Generate a random data bag secret'
            c.description = 'Generate a random data bag secret'
            databag_secret_action c
          end
        end
      end
    end
  end
end
