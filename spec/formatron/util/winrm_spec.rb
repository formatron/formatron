require 'spec_helper'

require 'formatron/util/winrm'

class Formatron
  # namespacing for tests
  module Util
    describe WinRM do
      before :each do
        stub_const 'Formatron::LOG', Logger.new('/dev/null')
        @hostname = 'hostname'
        @administrator_name = 'administrator_name'
        @administrator_password = 'administrator_password'
        endpoint = "http://#{@hostname}:5985/wsman"
        web_service_class = class_double(
          'WinRM::WinRMWebService'
        ).as_stubbed_const
        @web_service = instance_double 'WinRM::WinRMWebService'
        allow(web_service_class).to receive(:new).with(
          endpoint,
          :negotiate,
          user: @administrator_name,
          pass: @administrator_password
        ) { @web_service }
        @executor = instance_double 'WinRM::CommandExecutor'
        allow(@web_service).to receive(:create_executor) do |&block|
          block.call @executor
        end
      end

      describe '#exec' do
        command = 'command'

        context 'when the command fails to start' do
          before :each do
            expect(@executor).to receive(:run_powershell_script).with(
              command
            ) { fail 'error' }
          end

          it 'should raise an error' do
            expect do
              WinRM.exec(
                hostname: @hostname,
                administrator_name: @administrator_name,
                administrator_password: @administrator_password,
                command: command
              )
            end.to raise_error 'error'
          end
        end

        context 'when no error is encountered' do
          before :each do
            expect(@executor).to receive(:run_powershell_script).with(
              command
            ) do |&block|
              block.call 'stdout', 'stderr'
              { exitcode: 0 }
            end
          end

          it 'should use SSH to run the chef-client on the host directly' do
            WinRM.exec(
              hostname: @hostname,
              administrator_name: @administrator_name,
              administrator_password: @administrator_password,
              command: command
            )
          end
        end

        context 'when the command exits with a non zero code' do
          before :each do
            expect(@executor).to receive(:run_powershell_script).with(
              command
            ) { { exitcode: 1 } }
          end

          it 'should raise an error' do
            expect do
              WinRM.exec(
                hostname: @hostname,
                administrator_name: @administrator_name,
                administrator_password: @administrator_password,
                command: command
              )
            end.to raise_error "`#{command}` exited with code 1"
          end
        end
      end
    end
  end
end
