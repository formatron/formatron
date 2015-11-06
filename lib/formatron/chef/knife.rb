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
        @knife_file = Tempfile.new('formatron-knife-')
        @knife_file.write <<-EOH.gsub(/^ {10}/, '')
          chef_server_url '#{chef_server_url}'
          validation_client_name '#{organization}-validator'
          validation_key '#{keys.organization_key}'
          node_name '#{username}'
          client_key '#{keys.user_key}'
          ssl_verify_mode #{ssl_verify ? ':verify_peer' : ':verify_none'}
        EOH
        @knife_file.close
      end
      # rubocop:enable Metrics/MethodLength

      def create_environment(environment:)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "chef exec knife environment show #{environment} -c #{@knife_file.path}"
        Util::KernelHelper.shell "chef exec knife environment create #{environment} -c #{@knife_file.path} -d '#{environment} environment created by formatron'" unless Util::KernelHelper.success?
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
          Util::KernelHelper.shell "chef exec knife bootstrap #{hostname} --sudo -x ubuntu -i #{private_key} -E #{environment} -r #{cookbook} -N #{environment} -c #{@knife_file.path}"
        else
          Util::KernelHelper.shell "chef exec knife bootstrap #{hostname} --sudo -x ubuntu -i #{private_key} -E #{environment} -r #{cookbook} -G ubuntu@#{bastion_hostname} -N #{environment} -c #{@knife_file.path}"
        end
        fail "failed to bootstrap instance: #{hostname}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
