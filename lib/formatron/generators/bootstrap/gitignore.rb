module Formatron
  module Generators
    module Bootstrap
      # generates placeholder README.md
      module Gitignore
        def self.write(directory)
          FileUtils.mkdir_p directory
          readme = File.join directory, '.gitignore'
          File.write readme, <<-EOH.gsub(/^ {12}/, '')
            /.formatron/
          EOH
        end
      end
    end
  end
end
