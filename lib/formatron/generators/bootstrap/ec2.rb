module Formatron
  module Generators
    module Bootstrap
      # generates placeholder README.md
      module EC2
        def self.write(directory)
          ec2_directory = File.join directory, 'ec2'
          FileUtils.mkdir_p ec2_directory
          private_key = File.join ec2_directory, 'private-key.pem'
          File.write private_key, <<-EOH.gsub(/^ {12}/, '')
            Remember to replace this file with the EC2 private key
          EOH
        end
      end
    end
  end
end
