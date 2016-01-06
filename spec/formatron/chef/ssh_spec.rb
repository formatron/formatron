require 'spec_helper'

require 'formatron/chef/ssh'

class Formatron
  # rubocop:disable Metrics/ClassLength
  class Chef
    describe SSH do
      ec2_key = 'ec2_key'

      before :each do
        keys = instance_double 'Formatron::Chef::Keys'
        allow(keys).to receive(:ec2_key) { ec2_key }
        @net_ssh_class = class_double('Net::SSH').as_stubbed_const
        @net_ssh_session = instance_double 'Net::SSH::Connection::Session'
        @net_ssh_channel = instance_double 'Net::SSH::Connection::Channel'
        allow(@net_ssh_session).to receive :loop
        allow(@net_ssh_session).to receive(:open_channel) do |&block|
          block.call @net_ssh_channel
        end
        @ssh = SSH.new keys: keys
      end

      describe '#run_chef_client' do
        hostname = 'hostname'
        user = 'ubuntu'

        shared_context 'run_chef_client' do
          context 'when the command fails to start' do
            before :each do
              expect(@net_ssh_channel).to receive(:exec).with(
                'sudo chef-client'
              ) do |&block|
                block.call @net_ssh_channel, false
              end
            end

            it 'should raise an error' do
              expect do
                @ssh.run_chef_client(
                  hostname: hostname,
                  bastion_hostname: @bastion_hostname
                )
              end.to raise_error
            end
          end

          context 'when the command succeeds' do
            before :each do
              expect(@net_ssh_channel).to receive(:exec).with(
                'sudo chef-client'
              ) do |&block|
                block.call @net_ssh_channel, true
              end
              allow(@net_ssh_channel).to receive(:on_data) do |&block|
                block.call @net_ssh_channel, 'data'
              end
              allow(@net_ssh_channel).to receive(:on_extended_data) do |&block|
                block.call @net_ssh_channel, 'type', 'data'
              end
            end

            context 'when no error is encountered' do
              before :each do
                expect(@net_ssh_channel).to receive(:on_request).with(
                  'exit-status'
                ) do |&block|
                  block.call @net_ssh_channel, 0
                end
              end

              it 'should use SSH to run the chef-client on the host directly' do
                @ssh.run_chef_client(
                  hostname: hostname,
                  bastion_hostname: @bastion_hostname
                )
              end
            end

            context 'when the command exits with a non zero code' do
              before :each do
                expect(@net_ssh_channel).to receive(:on_request).with(
                  'exit-status'
                ) do |&block|
                  block.call @net_ssh_channel, 1
                end
              end

              it 'should raise an error' do
                expect do
                  @ssh.run_chef_client(
                    hostname: hostname,
                    bastion_hostname: @bastion_hostname
                  )
                end.to raise_error
              end
            end
          end
        end

        context 'when the host is also the bastion' do
          before :each do
            @bastion_hostname = hostname
            allow(@net_ssh_class).to receive(:start).with(
              hostname,
              user,
              keys: [ec2_key],
              proxy: nil
            ) do |&block|
              block.call @net_ssh_session
            end
          end

          include_context 'run_chef_client'
        end

        context 'when the host is not the bastion' do
          bastion_hostname = 'bastion_hostname'

          before :each do
            @bastion_hostname = bastion_hostname
            proxy_command_class = class_double(
              'Net::SSH::Proxy::Command'
            ).as_stubbed_const
            proxy_command = instance_double 'Net::SSH::Proxy::Command'
            allow(proxy_command_class).to receive(:new).with(
              "ssh #{user}@#{bastion_hostname} -W %h:%p"
            ) { proxy_command }
            allow(@net_ssh_class).to receive(:start).with(
              hostname,
              user,
              keys: [ec2_key],
              proxy: proxy_command
            ) do |&block|
              block.call @net_ssh_session
            end
          end

          include_context 'run_chef_client'
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end