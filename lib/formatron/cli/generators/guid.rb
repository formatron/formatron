require 'formatron/generators/util'

class Formatron
  class CLI
    module Generators
      # CLI command for GUID generator
      module GUID
        def guid_action(c)
          c.action do |_args, _options|
            puts Formatron::Generators::Util.guid
          end
        end

        def guid_formatron_command
          command :'generate guid' do |c|
            c.syntax = 'formatron generate guid [options]'
            c.summary = 'Generate a random GUID'
            c.description = 'Generate a random GUID'
            guid_action c
          end
        end
      end
    end
  end
end
