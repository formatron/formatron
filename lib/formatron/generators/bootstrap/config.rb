module Formatron
  module Generators
    module Bootstrap
      # generates an empty config
      module Config
        def self.write(directory, target)
          target_directory = File.join directory, 'config', target
          FileUtils.mkdir_p target_directory
          default_json = File.join target_directory, '_default.json'
          File.write default_json, <<-EOH.gsub(/^ {12}/, '')
            {
            }
          EOH
        end
      end
    end
  end
end
