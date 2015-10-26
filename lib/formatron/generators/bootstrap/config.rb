class Formatron
  module Generators
    module Bootstrap
      # generates an empty config
      module Config
        def self.write_default(file)
          File.write file, <<-EOH.gsub(/^ {12}/, '')
            {
            }
          EOH
        end

        # rubocop:disable Metrics/MethodLength
        def self.write_target(file, target, protect)
          File.write file, <<-EOH.gsub(/^ {12}/, '')
            {
              "protected": #{protect},
              "bastion": {
                "sub_domain": "bastion-#{target}"
              },
              "nat": {
                "sub_domain": "nat-#{target}"
              },
              "chef_server": {
                "sub_domain": "chef-#{target}"
              }
            }
          EOH
        end
        # rubocop:enable Metrics/MethodLength

        def self.write(directory, target = nil, protect = true)
          target_directory = File.join(
            directory,
            'config',
            target.nil? ? '_default' : target.to_s
          )
          FileUtils.mkdir_p target_directory
          file = File.join target_directory, '_default.json'
          write_default(file) if target.nil?
          write_target(file, target, protect) unless target.nil?
        end
      end
    end
  end
end
