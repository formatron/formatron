require 'net/ssh'
require 'formatron/logger'

class Formatron
  class Chef
    # Perform commands on chef nodes over SSH
    class SSH
      def initialize(keys:)
        @keys = keys
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def run_chef_client(hostname:, bastion_hostname:)
        proxy_command = Net::SSH::Proxy::Command.new(
          "ssh ubuntu@#{bastion_hostname} -W %h:%p"
        ) unless hostname.eql? bastion_hostname
        Net::SSH.start(
          hostname,
          'ubuntu',
          keys: [@keys.ec2_key],
          proxy: proxy_command
        ) do |ssh|
          ssh.open_channel do |channel|
            channel.exec('sudo chef-client') do |_ch, success|
              fail 'Failed to start chef-client' unless success
              channel.on_request('exit-status') do |_ch, data|
                fail "chef-client exited with code #{data}" if data != 0
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
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
