require 'formatron/project'

class Formatron
  module Support
    # Generates a Formatron project directory tree with the given files
    class FormatronProject
      attr_reader :files, :dir
      attr_accessor :cloudformation_stack_exists

      def initialize
        @cloudformation_stack_exists = false
        @files = {}
      end

      def add_file(relative_path, content)
        @files[relative_path] = content
      end

      def deploy(target)
        Dir.mktmpdir do |dir|
          @dir = dir
          @files.each do |relative_path, content|
            path = File.join dir, relative_path
            FileUtils.mkdir_p File.dirname(path)
            File.write path, content
          end
          Formatron::Project.new(dir, target).deploy
        end
      end
    end
  end
end
