require 'winrm'
require 'formatron/logger'

class Formatron
  module Util
    # Perform commands on chef nodes over WinRM
    class WinRM
      # rubocop:disable Metrics/MethodLength
      def self.exec(
        hostname:,
        administrator_name:,
        administrator_password:,
        command:
      )
        endpoint = "http://#{hostname}:5985/wsman"
        winrm = ::WinRM::WinRMWebService.new(
          endpoint,
          :negotiate,
          user: administrator_name,
          pass: administrator_password
        )
        output = winrm.create_executor do |executor|
          executor.run_powershell_script(command) do |stdout, stderr|
            stdout.each_line do |line|
              Formatron::LOG.info { line.chomp }
            end unless stdout.nil?
            stderr.each_line do |line|
              Formatron::LOG.warn { line.chomp }
            end unless stderr.nil?
          end
        end
        exitcode = output[:exitcode]
        fail(
          "`#{command}` exited with code #{exitcode}"
        ) unless exitcode == 0
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
