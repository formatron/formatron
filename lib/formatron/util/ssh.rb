require 'net/ssh'
require 'net/ssh/proxy/command'
require 'formatron/logger'

class Formatron
  module Util
    # Perform commands on chef nodes over SSH
    class SSH
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.exec(hostname:, bastion_hostname:, user:, key:, command:)
        proxy_command = Net::SSH::Proxy::Command.new(
          "ssh -o StrictHostKeyChecking=no #{user}@#{bastion_hostname} -W %h:%p"
        ) unless hostname.eql? bastion_hostname
        Net::SSH.start(
          hostname,
          user,
          keys: [key],
          proxy: proxy_command,
          paranoid: false
        ) do |ssh|
          ssh.open_channel do |channel|
            channel.exec(command) do |_ch, success|
              fail "failed to start command: #{command}" unless success
              channel.on_request('exit-status') do |_ch, data|
                status = data.read_long
                fail "`#{command}` exited with code #{status}" if status != 0
              end
              channel.on_data do |_ch, data|
                data.each_line do |line|
                  Formatron::LOG.info { line.chomp }
                end
              end
              channel.on_extended_data do |_ch, _type, data|
                data.each_line do |line|
                  Formatron::LOG.info { line.chomp }
                end
              end
            end
          end
          ssh.loop
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
