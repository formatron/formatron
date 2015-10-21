module Formatron
  module Generators
    module Bootstrap
      # generates placeholder SSL stuff
      module SSL
        def self.write(directory, target)
          target_directory = File.join directory, 'ssl', target.to_s
          FileUtils.mkdir_p target_directory
          placeholder_key = File.join target_directory, 'key'
          placeholder_cert = File.join target_directory, 'cert'
          File.write placeholder_key, <<-EOH.gsub(/^ {12}/, '')
            Remember to generate an SSL key
          EOH
          File.write placeholder_cert, <<-EOH.gsub(/^ {12}/, '')
            Remember to generate an SSL certificate
          EOH
        end
      end
    end
  end
end
