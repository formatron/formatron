module Formatron
  # command completion utilities
  module Completion
    def self.normalize_commands(commands)
      commands.map { |command| command.split.join ' ' }
    end

    def self.filter_commands(entered, commands)
      commands.select! do |command|
        command.start_with? entered
      end
    end

    def self.shift_commands(entered, current_word, commands)
      length = entered.split.length
      commands.map! do |command|
        components = command.split
        if length > 0
          components.shift(length - 1)
          components.shift if current_word.eql? ''
        end
        components[0]
      end
    end

    def self.complete(entered, current_word, commands)
      commands = normalize_commands commands
      filter_commands entered, commands
      shift_commands entered, current_word, commands
      commands.uniq.join ' '
    end

    # rubocop:disable Metrics/LineLength
    def self.completion_script(prefix)
      <<-EOH.gsub(/^ {8}/, '')
        _formatron_complete()  {
          COMPREPLY=()
          local word="${COMP_WORDS[COMP_CWORD]}"
          local completions=$(#{prefix} ${COMP_WORDS[0]} complete "${COMP_LINE}" "$word")
          COMPREPLY=( $(compgen -W "$completions" -- "$word") )
        }

        complete -F _formatron_complete formatron
      EOH
    end
    # rubocop:enable Metrics/LineLength
  end
end
