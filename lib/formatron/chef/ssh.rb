require 'formatron/util/ssh'

class Formatron
  class Chef
    # Perform commands on chef nodes over SSH
    class SSH
      SSH_USER = 'ubuntu'

      def initialize(keys:)
        @keys = keys
      end

      def run_chef_client(hostname:, bastion_hostname:)
        Formatron::Util::SSH.exec(
          hostname: hostname,
          bastion_hostname: bastion_hostname,
          user: SSH_USER,
          key: @keys.ec2_key,
          command: 'sudo chef-client'
        )
      end

      def bootstrapped?(hostname:, bastion_hostname:)
        Formatron::Util::SSH.exec(
          hostname: hostname,
          bastion_hostname: bastion_hostname,
          user: SSH_USER,
          key: @keys.ec2_key,
          command: '[ -f /etc/chef/client.pem ]'
        )
        true
      rescue
        false
      end
    end
  end
end
