require 'spec_helper'

require 'formatron/util/ssh'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module Util
    describe SSH do
      before :each do
        stub_const 'Formatron::LOG', Logger.new('/dev/null')
        @net_ssh_class = class_double('Net::SSH').as_stubbed_const
        @net_ssh_session = instance_double 'Net::SSH::Connection::Session'
        @net_ssh_channel = instance_double 'Net::SSH::Connection::Channel'
        allow(@net_ssh_session).to receive :loop
        allow(@net_ssh_session).to receive(:open_channel) do |&block|
          block.call @net_ssh_channel
        end
      end

      describe '#exec' do
        hostname = 'hostname'
        user = 'ubuntu'
        key = 'key'
        command = 'command'

        shared_context 'exec' do
          context 'when the command fails to start' do
            before :each do
              expect(@net_ssh_channel).to receive(:exec).with(
                command
              ) do |&block|
                block.call @net_ssh_channel, false
              end
            end

            it 'should raise an error' do
              expect do
                SSH.exec(
                  hostname: hostname,
                  bastion_hostname: @bastion_hostname,
                  user: user,
                  key: key,
                  command: command
                )
              end.to raise_error "failed to start command: #{command}"
            end
          end

          context 'when the command succeeds' do
            before :each do
              expect(@net_ssh_channel).to receive(:exec).with(
                command
              ) do |&block|
                block.call @net_ssh_channel, true
              end
              allow(@net_ssh_channel).to receive(:on_data) do |&block|
                block.call @net_ssh_channel, 'data'
              end
              allow(@net_ssh_channel).to receive(:on_extended_data) do |&block|
                block.call @net_ssh_channel, 'type', 'extended data'
              end
            end

            context 'when no error is encountered' do
              before :each do
                expect(@net_ssh_channel).to receive(:on_request).with(
                  'exit-status'
                ) do |&block|
                  block.call @net_ssh_channel, SSHData.new(0)
                end
              end

              it 'should use SSH to run the chef-client on the host directly' do
                SSH.exec(
                  hostname: hostname,
                  bastion_hostname: @bastion_hostname,
                  user: user,
                  key: key,
                  command: command
                )
              end
            end

            context 'when the command exits with a non zero code' do
              before :each do
                expect(@net_ssh_channel).to receive(:on_request).with(
                  'exit-status'
                ) do |&block|
                  block.call @net_ssh_channel, SSHData.new(1)
                end
              end

              it 'should raise an error' do
                expect do
                  SSH.exec(
                    hostname: hostname,
                    bastion_hostname: @bastion_hostname,
                    user: user,
                    key: key,
                    command: command
                  )
                end.to raise_error "`#{command}` exited with code 1"
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
              keys: [key],
              proxy: nil,
              paranoid: false
            ) do |&block|
              block.call @net_ssh_session
            end
          end

          include_context 'exec'
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
              'ssh -o StrictHostKeyChecking=no ' \
              "#{user}@#{bastion_hostname} -W %h:%p"
            ) { proxy_command }
            allow(@net_ssh_class).to receive(:start).with(
              hostname,
              user,
              keys: [key],
              proxy: proxy_command,
              paranoid: false
            ) do |&block|
              block.call @net_ssh_session
            end
          end

          include_context 'exec'
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
