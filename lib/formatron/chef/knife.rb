require 'formatron/util/kernel_helper'
require 'English'

class Formatron
  class Chef
    # Wrapper for the knife cli
    class Knife
      # rubocop:disable Metrics/MethodLength
      def initialize(
        keys:, chef_server_url:, username:, organization:, ssl_verify:
      )
        @ssl_verify = ssl_verify
        @knife_file = Tempfile.new('formatron-knife-')
        @knife_file.write <<-EOH.gsub(/^ {10}/, '')
          chef_server_url '#{chef_server_url}'
          validation_client_name '#{organization}-validator'
          validation_key '#{keys.organization_key}'
          node_name '#{username}'
          client_key '#{keys.user_key}'
          verify_api_cert #{@ssl_verify}
          ssl_verify_mode #{@ssl_verify ? ':verify_peer' : ':verify_none'}
        EOH
        @knife_file.close
      end
      # rubocop:enable Metrics/MethodLength

      def create_environment(environment:)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "knife environment show #{environment} -c #{@knife_file.path}"
        Util::KernelHelper.shell "knife environment create #{environment} -c #{@knife_file.path} -d '#{environment} environment created by formatron'" unless Util::KernelHelper.success?
        fail "failed to create opscode environment: #{environment}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end

      # rubocop:disable Metrics/MethodLength
      def bootstrap(
        environment:,
        bastion_hostname:,
        cookbook:,
        hostname:,
        private_key:
      )
        # rubocop:disable Metrics/LineLength
        if bastion_hostname.eql? hostname
          Util::KernelHelper.shell "knife bootstrap #{hostname} --sudo -x ubuntu -i #{private_key} -E #{environment} -r #{cookbook} -N #{environment} -c #{@knife_file.path}#{@ssl_verify ? '' : ' --node-ssl-verify-mode none'}"
        else
          Util::KernelHelper.shell "knife bootstrap #{hostname} --sudo -x ubuntu -i #{private_key} -E #{environment} -r #{cookbook} -G ubuntu@#{bastion_hostname} -N #{environment} -c #{@knife_file.path}#{@ssl_verify ? '' : ' --node-ssl-verify-mode none'}"
        end
        fail "failed to bootstrap instance: #{hostname}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end
      # rubocop:enable Metrics/MethodLength

      def delete_node(node:)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "knife node delete #{node} -y -c #{@knife_file.path}"
        fail "failed to delete node: #{node}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end

      def delete_client(client:)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "knife client delete #{client} -y -c #{@knife_file.path}"
        fail "failed to delete client: #{client}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end

      def delete_environment(environment:)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "knife environment delete #{environment} -y -c #{@knife_file.path}"
        fail "failed to delete environment: #{environment}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
