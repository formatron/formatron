require_relative '../completion'

module Formatron
  module Completion
    # CLI command for completion enabling script
    module CompletionScriptCLI
      def completion_script_action(c)
        c.action do |args|
          print Completion.completion_script args[0]
        end
      end

      def completion_script_formatron_command
        command :'completion-script' do |c|
          c.syntax = 'formatron completion-script PREFIX'
          c.summary = 'Print a bash completion script to ' \
                      'enable command completion'
          c.description = 'Print a bash completion script to ' \
                          'enable command completion'
          completion_script_action c
        end
      end
    end
  end
end
