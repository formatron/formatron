class Formatron
  module Generators
    module Bootstrap
      # generates placeholder README.md
      module Readme
        def self.write(directory, name)
          FileUtils.mkdir_p directory
          readme = File.join directory, 'README.md'
          File.write readme, <<-EOH.gsub(/^ {12}/, '')
            # #{name}

            Bootstrap Formatron configuration
          EOH
        end
      end
    end
  end
end
