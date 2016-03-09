require 'formatron/util/shell'
require 'English'

class Formatron
  class Chef
    # Wrapper for the berkshelf cli
    class Berkshelf
      CONFIG_FILE_CONTENTS = <<-EOH.gsub(/^ {8}/, '')
        {
          "chef": {
            "chef_server_url": "%{server_url}",
            "node_name": "%{user}",
            "client_key": "%{key_file}"
          },
          "ssl": {
            "verify": %{ssl_verify}
          }
        }
      EOH
      CONFIG_FILE = 'berkshelf.json'

      # rubocop:disable Metrics/MethodLength
      def initialize(
        directory:,
        keys:,
        chef_server_url:,
        username:,
        ssl_verify:
      )
        @config_file = File.join directory, CONFIG_FILE
        @keys = keys
        @chef_server_url = chef_server_url
        @username = username
        @ssl_verify = ssl_verify
      end
      # rubocop:enable Metrics/MethodLength

      def init
        File.write(@config_file, CONFIG_FILE_CONTENTS % {
          server_url: @chef_server_url,
          user: @username,
          key_file: @keys.user_key,
          ssl_verify: @ssl_verify
        })
      end

      def upload(cookbook:, environment:)
        # rubocop:disable Metrics/LineLength
        command = "berks install -b #{File.join(cookbook, 'Berksfile')}"
        fail "failed to download cookbooks for opscode environment: #{environment}" unless Util::Shell.exec command
        command = "berks upload -c #{@config_file} -b #{File.join(cookbook, 'Berksfile')}"
        fail "failed to upload cookbooks for opscode environment: #{environment}" unless Util::Shell.exec command
        command = "berks apply #{environment} -c #{@config_file} -b #{File.join(cookbook, 'Berksfile.lock')}"
        fail "failed to apply cookbooks to opscode environment: #{environment}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
