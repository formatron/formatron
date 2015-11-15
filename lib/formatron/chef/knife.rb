require 'formatron/util/shell'
require 'English'

class Formatron
  class Chef
    # Wrapper for the knife cli
    class Knife
      def initialize(
        keys:, chef_server_url:, username:, organization:, ssl_verify:
      )
        @keys = keys
        @chef_server_url = chef_server_url
        @username = username
        @organization = organization
        @ssl_verify = ssl_verify
      end

      # rubocop:disable Metrics/MethodLength
      def init
        @knife_file = Tempfile.new('formatron-knife-')
        @knife_file.write <<-EOH.gsub(/^ {10}/, '')
          chef_server_url '#{@chef_server_url}'
          validation_client_name '#{@organization}-validator'
          validation_key '#{@keys.organization_key}'
          node_name '#{@username}'
          client_key '#{@keys.user_key}'
          verify_api_cert #{@ssl_verify}
          ssl_verify_mode #{@ssl_verify ? ':verify_peer' : ':verify_none'}
        EOH
        @knife_file.close
      end
      # rubocop:enable Metrics/MethodLength

      def create_environment(environment:)
        # rubocop:disable Metrics/LineLength
        _attempt_to_create_environment environment unless _environment_exists environment
        # rubocop:enable Metrics/LineLength
      end

      def _environment_exists(environment)
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife environment show #{environment} -c #{@knife_file.path}"
        # rubocop:enable Metrics/LineLength
      end

      def _attempt_to_create_environment(environment)
        # rubocop:disable Metrics/LineLength
        fail "failed to create opscode environment: #{environment}" unless _create_environment environment
        # rubocop:enable Metrics/LineLength
      end

      def _create_environment(environment)
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife environment create #{environment} -c #{@knife_file.path} -d '#{environment} environment created by formatron'"
        # rubocop:enable Metrics/LineLength
      end

      def bootstrap(
        environment:,
        bastion_hostname:,
        cookbook:,
        hostname:
      )
        # rubocop:disable Metrics/LineLength
        command = "knife bootstrap #{hostname} --sudo -x ubuntu -i #{@keys.ec2_key} -E #{environment} -r #{cookbook} -N #{environment} -c #{@knife_file.path}#{@ssl_verify ? '' : ' --node-ssl-verify-mode none'}"
        command = "#{command} -G ubuntu@#{bastion_hostname}" unless bastion_hostname.eql? hostname
        fail "failed to bootstrap instance: #{hostname}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def delete_node(node:)
        command = "knife node delete #{node} -y -c #{@knife_file.path}"
        fail "failed to delete node: #{node}" unless Util::Shell.exec command
      end

      def delete_client(client:)
        # rubocop:disable Metrics/LineLength
        command = "knife client delete #{client} -y -c #{@knife_file.path}"
        fail "failed to delete client: #{client}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def delete_environment(environment:)
        # rubocop:disable Metrics/LineLength
        command = "knife environment delete #{environment} -y -c #{@knife_file.path}"
        fail "failed to delete environment: #{environment}" unless Util::Shell.exec command
        # rubocop:enable Metrics/LineLength
      end

      def unlink
        @knife_file.unlink unless @knife_file.nil?
      end

      private(
        :_create_environment,
        :_attempt_to_create_environment,
        :_environment_exists
      )
    end
  end
end
