class Formatron
  module Generators
    module Instance
      # generates an empty config
      module Config
        def self.write_default(file)
          File.write file, <<-EOH.gsub(/^ {12}/, '')
            {
            }
          EOH
        end

        def self.write_target(file, target, name)
          File.write file, <<-EOH.gsub(/^ {12}/, '')
            {
              "#{name}": {
                "sub_domain": "#{name}-#{target}"
              }
            }
          EOH
        end

        # rubocop:disable Metrics/MethodLength
        def self.write(
          directory,
          target = nil,
          name = nil
        )
          target_directory = File.join(
            directory,
            'config',
            target.nil? ? '_default' : target.to_s
          )
          FileUtils.mkdir_p target_directory
          file = File.join target_directory, '_default.json'
          write_default(file) if target.nil?
          write_target(
            file,
            target,
            name
          ) unless target.nil?
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
