require 'spec_helper'

require 'formatron/chef/ssh'

class Formatron
  # namespacing for tests
  class Chef
    describe SSH do
      ec2_key = 'ec2_key'
      hostname = 'hostname'
      bastion_hostname = 'bastion_hostname'
      user = 'ubuntu'
      error = 'command failed'

      before :each do
        keys = instance_double 'Formatron::Chef::Keys'
        allow(keys).to receive(:ec2_key) { ec2_key }
        @util_ssh_class = class_double('Formatron::Util::SSH').as_stubbed_const
        @ssh = SSH.new keys: keys
      end

      describe '#run_chef_client' do
        # use the first-boot.json to ensure the runlist is correct
        # if the node fails to converge the first time (in which case
        # the server will show an empty run list for the node)
        command = 'sudo chef-client -j /etc/chef/first-boot.json'

        context 'when the ssh command fails' do
          before :each do
            expect(@util_ssh_class).to receive(:exec).with(
              hostname: hostname,
              bastion_hostname: bastion_hostname,
              user: user,
              key: ec2_key,
              command: command
            ) { fail error }
          end

          it 'should raise an error' do
            expect do
              @ssh.run_chef_client(
                hostname: hostname,
                bastion_hostname: bastion_hostname
              )
            end.to raise_error error
          end
        end

        context 'when the ssh command succeeds' do
          before :each do
            expect(@util_ssh_class).to receive(:exec).with(
              hostname: hostname,
              bastion_hostname: bastion_hostname,
              user: user,
              key: ec2_key,
              command: command
            )
          end

          it 'should succeed' do
            @ssh.run_chef_client(
              hostname: hostname,
              bastion_hostname: bastion_hostname
            )
          end
        end
      end

      describe '#bootstrapped?' do
        command = '[ -f /etc/chef/client.pem ]'

        context 'when the ssh command fails' do
          before :each do
            expect(@util_ssh_class).to receive(:exec).with(
              hostname: hostname,
              bastion_hostname: bastion_hostname,
              user: user,
              key: ec2_key,
              command: command
            ) { fail error }
          end

          it 'should return false' do
            expect(
              @ssh.bootstrapped?(
                hostname: hostname,
                bastion_hostname: bastion_hostname
              )
            ).to eql false
          end
        end

        context 'when the ssh command succeeds' do
          before :each do
            expect(@util_ssh_class).to receive(:exec).with(
              hostname: hostname,
              bastion_hostname: bastion_hostname,
              user: user,
              key: ec2_key,
              command: command
            )
          end

          it 'should return true' do
            expect(
              @ssh.bootstrapped?(
                hostname: hostname,
                bastion_hostname: bastion_hostname
              )
            ).to eql true
          end
        end
      end
    end
  end
end
