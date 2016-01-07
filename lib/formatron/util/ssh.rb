require 'net/ssh'
require 'formatron/logger'

class Formatron
  module Util
    # Perform commands on chef nodes over SSH
    class SSH
      # rubocop:disable Metrics/MethodLength
      def self.exec(hostname:, bastion_hostname:, user:, key:, command:)
        proxy_command = Net::SSH::Proxy::Command.new(
          "ssh #{user}@#{bastion_hostname} -W %h:%p"
        ) unless hostname.eql? bastion_hostname
        Net::SSH.start(
          hostname,
          user,
          keys: [key],
          proxy: proxy_command
        ) do |ssh|
          ssh.open_channel do |channel|
            channel.exec(command) do |_ch, success|
              fail "failed to start command: #{command}" unless success
              channel.on_request('exit-status') do |_ch, data|
                fail "`#{command}` exited with code #{data}" if data != 0
              end
              channel.on_data do |_ch, data|
                Formatron::LOG.info { data }
              end
              channel.on_extended_data do |_ch, _type, data|
                Formatron::LOG.info { data }
              end
            end
          end
          ssh.loop
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
