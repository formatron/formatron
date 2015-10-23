require_relative '../completion'

module Formatron
  module Completion
    # CLI command for completion
    module CompleteCLI
      def complete_action(c)
        c.action do |args|
          entered = args[0].split
          entered.shift
          entered.shift if entered[0].eql? 'help'
          entered = entered.join ' '
          current_word = args[1] || ''
          print Completion.complete entered, current_word, defined_commands.keys
        end
      end

      def complete_formatron_command
        command :complete do |c|
          c.syntax = 'formatron complete CURRENT_LINE CURRENT_WORD'
          c.summary = 'check the supplied line and word and suggest ' \
                      'a list of command completions'
          c.description = 'check the supplied line and word and suggest ' \
                          'a list of command completions'
          complete_action c
        end
      end
    end
  end
end
