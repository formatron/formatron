require 'formatron/util/winrm'

class Formatron
  class Chef
    # Perform commands on chef nodes over WinRM
    class WinRM
      def initialize(administrator_name:, administrator_password:)
        @administrator_name = administrator_name
        @administrator_password = administrator_password
      end

      def run_chef_client(hostname:)
        # use the first-boot.json to ensure the runlist is correct
        # if the node fails to converge the first time (in which case
        # the server will show an empty run list for the node)
        Formatron::Util::WinRM.exec(
          hostname: hostname,
          administrator_name: @administrator_name,
          administrator_password: @administrator_password,
          command: 'chef-client -j C:\chef\first-boot.json'
        )
      end

      def bootstrapped?(hostname:)
        Formatron::Util::WinRM.exec(
          hostname: hostname,
          administrator_name: @administrator_name,
          administrator_password: @administrator_password,
          command: 'if (-not (Test-Path C:\chef\client.pem)) { exit 1 }'
        )
        true
      rescue
        false
      end
    end
  end
end
