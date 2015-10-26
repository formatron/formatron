class Formatron
  module Generators
    module Bootstrap
      # generates placeholder SSL stuff
      module SSL
        def self.write_key(directory)
          placeholder_key = File.join directory, 'key'
          File.write placeholder_key, <<-EOH.gsub(/^ {12}/, '')
            Remember to generate an SSL key
          EOH
        end

        def self.write_cert(directory)
          placeholder_cert = File.join directory, 'cert'
          File.write placeholder_cert, <<-EOH.gsub(/^ {12}/, '')
            Remember to generate an SSL certificate
          EOH
        end

        def self.write(directory, target)
          target_directory = File.join(
            directory,
            'config',
            target.to_s,
            'chef_server',
            'ssl'
          )
          FileUtils.mkdir_p target_directory
          write_key target_directory
          write_cert target_directory
        end
      end
    end
  end
end
