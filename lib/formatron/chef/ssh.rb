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
        # use the first-boot.json to ensure the runlist is correct
        # if the node fails to converge the first time (in which case
        # the server will show an empty run list for the node)
        Formatron::Util::SSH.exec(
          hostname: hostname,
          bastion_hostname: bastion_hostname,
          user: SSH_USER,
          key: @keys.ec2_key,
          command: 'sudo chef-client -j /etc/chef/first-boot.json'
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
