class Formatron
  module Cucumber
    module Support
      # Generates a Formatron project directory tree with the given files
      class FormatronProject
        attr_reader :files

        def initialize
          @files = {}
        end

        def add_file(relative_path, content)
          @files[relative_path] = content
        end

        def deploy(target)
          Dir.mktmpdir do |dir|
            @files.each do |relative_path, content|
              path = File.join dir, relative_path
              FileUtils.mkdir_p File.dirname(path)
              File.write path, content
            end
            Formatron.new(dir, target).deploy
          end
        end
      end
    end
  end
end
