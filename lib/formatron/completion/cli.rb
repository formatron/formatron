require_relative '../completion'

module Formatron
  module Completion
    # CLI command for completion enabling script
    module CLI
      def completion_script_action(c)
        c.action do |args|
          command = args[0] || 'formatron'
          print Completion.script command, defined_commands.keys
        end
      end

      def completion_script_formatron_command
        command :'completion-script' do |c|
          c.syntax = 'formatron completion-script [COMMAND]'
          c.summary = 'Output a bash script to ' \
                      'enable command completion'
          c.description = 'Output a bash script to ' \
                          'enable command completion'
          completion_script_action c
        end
      end
    end
  end
end
