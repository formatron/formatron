class Formatron
  # command completion utilities
  module Completion
    # exports commands, etc to completion script ERB template
    class Template
      attr_reader :subcommands, :command

      def initialize(command, subcommands)
        @command = command
        @subcommands = subcommands
      end
    end

    def self.script(command, subcommands)
      template = File.join(
        File.dirname(File.expand_path(__FILE__)),
        'completion',
        'completion.sh.erb'
      )
      erb = ERB.new File.read(template)
      erb.filename = template
      erb_template = erb.def_class Template, 'render()'
      erb_template.new(command, subcommands).render
    end
  end
end
