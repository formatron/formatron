require 'formatron/util/shell'
require 'English'
require 'json'

class Formatron
  class Chef
    # Wrapper for the knife cli
    # rubocop:disable Metrics/ClassLength
    class Knife
      CONFIG_FILE = 'knife.rb'
      DATABAG_SECRET_FILE = 'databag_secret'
      DATABAG_DIRECTORY = 'databag'
      DATABAG_ITEM_SUFFIX = '.json'

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        directory:,
        keys:,
        administrator_name:,
        administrator_password:,
        chef_server_url:,
        username:,
        organization:,
        ssl_verify:,
        databag_secret:,
        configuration:
      )
        @knife_file = File.join directory, CONFIG_FILE
        @databag_secret_file = File.join directory, DATABAG_SECRET_FILE
        @databag_directory = File.join directory, DATABAG_DIRECTORY
        @keys = keys
        @administrator_name = administrator_name
        @administrator_password = administrator_password
        @chef_server_url = chef_server_url
        @username = username
        @organization = organization
        @ssl_verify = ssl_verify
        @databag_secret = databag_secret
        @configuration = configuration
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def init
        File.write @knife_file, <<-EOH.gsub(/^ {10}/, '')
          chef_server_url '#{@chef_server_url}'
          validation_client_name '#{@organization}-validator'
          validation_key '#{@keys.organization_key}'
          node_name '#{@username}'
          client_key '#{@keys.user_key}'
          verify_api_cert #{@ssl_verify}
          ssl_verify_mode #{@ssl_verify ? ':verify_peer' : ':verify_none'}
        EOH
        File.write @databag_secret_file, @databag_secret
        FileUtils.mkdir_p @databag_directory
      end
      # rubocop:enable Metrics/MethodLength

      def deploy_databag(name:)
        databag_file = File.join(
          @databag_directory, "#{name}#{DATABAG_ITEM_SUFFIX}"
        )
        File.write databag_file, @configuration.merge(id: name).to_json
        _attempt_to_create_databag unless _databag_exists
        _attempt_to_create_databag_item(
          name: name,
          databag_file: databag_file
        )
      end

      def _databag_exists
        Util::Shell.exec "knife data bag show formatron -c #{@knife_file}"
      end

      def _attempt_to_create_databag
        fail 'failed to create data bag: formatron' unless _create_databag
      end

      def _create_databag
        Util::Shell.exec "knife data bag create formatron -c #{@knife_file}"
      end

      def _attempt_to_create_databag_item(name:, databag_file:)
        # rubocop:disable Metrics/LineLength
        fail "failed to create data bag item: #{name}" unless _create_databag_item databag_file: databag_file
        # rubocop:enable Metrics/LineLength
      end

      def _create_databag_item(databag_file:)
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife data bag from file formatron #{databag_file} --secret-file #{@databag_secret_file} -c #{@knife_file}"
        # rubocop:enable Metrics/LineLength
      end

      def create_environment(environment:)
        # rubocop:disable Metrics/LineLength
        _attempt_to_create_environment environment unless _environment_exists environment
        # rubocop:enable Metrics/LineLength
      end

      def _environment_exists(environment)
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife environment show #{environment} -c #{@knife_file}"
        # rubocop:enable Metrics/LineLength
      end

      def _attempt_to_create_environment(environment)
        # rubocop:disable Metrics/LineLength
        fail "failed to create opscode environment: #{environment}" unless _create_environment environment
        # rubocop:enable Metrics/LineLength
      end

      def _create_environment(environment)
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife environment create #{environment} -c #{@knife_file} -d '#{environment} environment created by formatron'"
        # rubocop:enable Metrics/LineLength
      end

      # rubocop:disable Metrics/MethodLength
      def bootstrap(
        os:,
        guid:,
        bastion_hostname:,
        cookbook:,
        hostname:
      )
        # rubocop:disable Metrics/LineLength
        if os.eql? 'windows'
          command = "knife bootstrap windows winrm #{hostname} -x #{@administrator_name} -P '#{@administrator_password}' -E #{guid} -r #{cookbook} -N #{guid} -c #{@knife_file} --secret-file #{@databag_secret_file}"
        else
          command = "knife bootstrap #{hostname} --sudo -x ubuntu -i #{@keys.ec2_key} -E #{guid} -r #{cookbook} -N #{guid} -c #{@knife_file}#{@ssl_verify ? '' : ' --node-ssl-verify-mode none'} --secret-file #{@databag_secret_file}"
          command = "#{command} -G ubuntu@#{bastion_hostname}" unless bastion_hostname.eql? hostname
        end
        fail "failed to bootstrap instance: #{guid}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end
      # rubocop:enable Metrics/MethodLength

      def delete_databag(name:)
        # rubocop:disable Metrics/LineLength
        command = "knife data bag delete formatron #{name} -y -c #{@knife_file}"
        fail "failed to delete data bag item: #{name}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def delete_node(node:)
        command = "knife node delete #{node} -y -c #{@knife_file}"
        fail "failed to delete node: #{node}" unless Util::Shell.exec command
      end

      def delete_client(client:)
        # rubocop:disable Metrics/LineLength
        command = "knife client delete #{client} -y -c #{@knife_file}"
        fail "failed to delete client: #{client}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def delete_environment(environment:)
        # rubocop:disable Metrics/LineLength
        command = "knife environment delete #{environment} -y -c #{@knife_file}"
        fail "failed to delete environment: #{environment}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def node_exists?(guid:)
        command = "knife node show #{guid} -c #{@knife_file}"
        Util::Shell.exec command
      end

      private(
        :_create_databag,
        :_create_databag_item,
        :_attempt_to_create_databag,
        :_attempt_to_create_databag_item,
        :_databag_exists,
        :_create_environment,
        :_attempt_to_create_environment,
        :_environment_exists
      )
    end
    # rubocop:enable Metrics/ClassLength
  end
end
