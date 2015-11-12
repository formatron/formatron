class Formatron
  module Generators
    module Util
      # generates placeholder README.md
      module Readme
        def self.write(directory, name)
          FileUtils.mkdir_p directory
          readme = File.join directory, 'README.md'
          File.write readme, <<-EOH.gsub(/^ {12}/, '')
            # #{name}

            Formatron configuration
          EOH
        end
      end
    end
  end
end
