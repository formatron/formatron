require 'spec_helper'

require 'formatron/chef/winrm'

class Formatron
  # namespacing for tests
  class Chef
    describe WinRM do
      administrator_name = 'administrator_name'
      administrator_password = 'administrator_password'
      hostname = 'hostname'
      error = 'command failed'

      before :each do
        @util_winrm_class = class_double(
          'Formatron::Util::WinRM'
        ).as_stubbed_const
        @winrm = WinRM.new(
          administrator_name: administrator_name,
          administrator_password: administrator_password
        )
      end

      describe '#run_chef_client' do
        # use the first-boot.json to ensure the runlist is correct
        # if the node fails to converge the first time (in which case
        # the server will show an empty run list for the node)
        command = 'chef-client -j C:\chef\first-boot.json'

        context 'when the winrm command fails' do
          before :each do
            expect(@util_winrm_class).to receive(:exec).with(
              hostname: hostname,
              administrator_name: administrator_name,
              administrator_password: administrator_password,
              command: command
            ) { fail error }
          end

          it 'should raise an error' do
            expect do
              @winrm.run_chef_client(
                hostname: hostname
              )
            end.to raise_error error
          end
        end

        context 'when the winrm command succeeds' do
          before :each do
            expect(@util_winrm_class).to receive(:exec).with(
              hostname: hostname,
              administrator_name: administrator_name,
              administrator_password: administrator_password,
              command: command
            )
          end

          it 'should succeed' do
            @winrm.run_chef_client(
              hostname: hostname
            )
          end
        end
      end

      describe '#bootstrapped?' do
        command = 'if (-not (Test-Path C:\chef\client.pem)) { exit 1 }'

        context 'when the winrm command fails' do
          before :each do
            expect(@util_winrm_class).to receive(:exec).with(
              hostname: hostname,
              administrator_name: administrator_name,
              administrator_password: administrator_password,
              command: command
            ) { fail error }
          end

          it 'should return false' do
            expect(
              @winrm.bootstrapped?(
                hostname: hostname
              )
            ).to eql false
          end
        end

        context 'when the winrm command succeeds' do
          before :each do
            expect(@util_winrm_class).to receive(:exec).with(
              hostname: hostname,
              administrator_name: administrator_name,
              administrator_password: administrator_password,
              command: command
            )
          end

          it 'should return true' do
            expect(
              @winrm.bootstrapped?(
                hostname: hostname
              )
            ).to eql true
          end
        end
      end
    end
  end
end
