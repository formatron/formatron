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
        def self.write_target(file, target, protect, cookbooks_bucket_prefix)
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
                "sub_domain": "chef-#{target}",
                "cookbooks_bucket": "#{cookbooks_bucket_prefix}-#{target}"
              }
            }
          EOH
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def self.write(
          directory,
          target = nil,
          protect = true,
          cookbooks_bucket_prefix = nil
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
            protect,
            cookbooks_bucket_prefix
          ) unless target.nil?
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
