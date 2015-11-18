require 'formatron/util/shell'
require 'English'
require 'json'

class Formatron
  class Chef
    # Wrapper for the knife cli
    # rubocop:disable Metrics/ClassLength
    class Knife
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        keys:,
        chef_server_url:,
        username:,
        organization:,
        ssl_verify:,
        name:,
        databag_secret:,
        configuration:
      )
        @keys = keys
        @chef_server_url = chef_server_url
        @username = username
        @organization = organization
        @ssl_verify = ssl_verify
        @name = name
        @databag_secret = databag_secret
        @configuration = configuration
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def init
        @knife_file = Tempfile.new 'formatron-knife-'
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
        @databag_secret_file = Tempfile.new 'formatron-databag-secret-'
        @databag_secret_file.write @databag_secret
        @databag_secret_file.close
        @databag_file = Tempfile.new 'formatron-databag-'
        @databag_file.write @configuration.merge(id: @name).to_json
        @databag_file.close
      end
      # rubocop:enable Metrics/MethodLength

      def deploy_databag
        _attempt_to_create_databag unless _databag_exists
        _attempt_to_create_databag_item
      end

      def _databag_exists
        Util::Shell.exec "knife data bag show formatron -c #{@knife_file.path}"
      end

      def _attempt_to_create_databag
        fail 'failed to create data bag: formatron' unless _create_databag
      end

      def _create_databag
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife data bag create formatron -c #{@knife_file.path}"
        # rubocop:enable Metrics/LineLength
      end

      def _attempt_to_create_databag_item
        # rubocop:disable Metrics/LineLength
        fail "failed to create data bag item: #{@name}" unless _create_databag_item
        # rubocop:enable Metrics/LineLength
      end

      def _create_databag_item
        # rubocop:disable Metrics/LineLength
        Util::Shell.exec "knife data bag from file formatron #{@databag_file.path} --secret-file #{@databag_secret_file.path} -c #{@knife_file.path}"
        # rubocop:enable Metrics/LineLength
      end

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
        command = "knife bootstrap #{hostname} --sudo -x ubuntu -i #{@keys.ec2_key} -E #{environment} -r #{cookbook} -N #{environment} -c #{@knife_file.path}#{@ssl_verify ? '' : ' --node-ssl-verify-mode none'} --secret-file #{@databag_secret_file.path}"
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
        @databag_secret_file.unlink unless @databag_secret_file.nil?
        @databag_file.unlink unless @databag_file.nil?
      end

      private(
        :_create_environment,
        :_attempt_to_create_environment,
        :_environment_exists
      )
    end
    # rubocop:enable Metrics/ClassLength
  end
end
