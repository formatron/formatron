require 'spec_helper'

require 'formatron/chef/knife'

ENVIRONMENT = 'env'
ENVIRONMENT_CHECK_COMMAND = 'chef exec knife environment ' \
                            "show #{ENVIRONMENT} " \
                            '-c knife_file'
ENVIRONMENT_CREATE_COMMAND = 'chef exec knife environment create ' \
                             "#{ENVIRONMENT} -c " \
                             "knife_file -d '#{ENVIRONMENT} environment " \
                             "created by formatron'"
BOOTSTRAP_COMMAND = 'chef exec knife bootstrap hostname ' \
                    '--sudo -x ubuntu -i private_key -E ' \
                    "#{ENVIRONMENT} -r cookbook -N hostname -c knife_file"
BOOTSTRAP_COMMAND_WITH_BASTION = 'chef exec knife bootstrap hostname ' \
                                 '--sudo -x ubuntu -i private_key -E ' \
                                 "#{ENVIRONMENT} -r cookbook -G " \
                                 'ubuntu@bastion -N hostname -c knife_file'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module Chef
    describe Knife do
      before(:each) do
        @keys = instance_double 'Formatron::Chef::Keys'
        @chef_server_url = 'chef_server_url'
        @username = 'username'
        @user_key = 'user_key'
        allow(@keys).to receive(:user_key) { @user_key }
        @organization = 'organization'
        @organization_key = 'organization_key'
        allow(@keys).to receive(:organization_key) { @organization_key }
        @knife_tempfile = instance_double('Tempfile')
        allow(@knife_tempfile).to receive(:write)
        allow(@knife_tempfile).to receive(:close)
        allow(@knife_tempfile).to receive(:path) do
          'knife_file'
        end
        @tempfile_class = class_double('Tempfile').as_stubbed_const
        allow(@tempfile_class).to receive(:new) { @knife_tempfile }
      end

      context 'when verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true
          )
        end

        it 'should create a temporary file for the knife ' \
           'config setting the verify mode to :verify_peer' do
          expect(@tempfile_class).to have_received(
            :new
          ).with('formatron-knife-')
          expect(@knife_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^ {14}/, '')
              chef_server_url '#{@chef_server_url}'
              validation_client_name '#{@organization}-validator'
              validation_key '#{@organization_key}'
              node_name '#{@username}'
              client_key '#{@user_key}'
              ssl_verify_mode :verify_peer
            EOH
          ).once
          expect(@knife_tempfile).to have_received(:close).with(no_args).once
        end
      end

      context 'when not verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: false
          )
        end

        it 'should create a temporary file for the knife ' \
           'config setting the verify mode to :verify_none' do
          expect(@tempfile_class).to have_received(
            :new
          ).with('formatron-knife-')
          expect(@knife_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^\ {14}/, '')
              chef_server_url '#{@chef_server_url}'
              validation_client_name '#{@organization}-validator'
              validation_key '#{@organization_key}'
              node_name '#{@username}'
              client_key '#{@user_key}'
              ssl_verify_mode :verify_none
            EOH
          ).once
          expect(@knife_tempfile).to have_received(:close).with(no_args).once
        end
      end

      describe '#create_environment' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true
          )
        end

        context 'when the environment already exists' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when ENVIRONMENT_CHECK_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { true }
              when ENVIRONMENT_CREATE_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { true }
              else
                allow(@kernel_helper_class).to receive(:success?) { false }
              end
            end
          end

          it 'should do nothing' do
            @knife.create_environment environment: ENVIRONMENT
            expect(@kernel_helper_class).to have_received(:shell).once
            expect(@kernel_helper_class).to have_received(:shell).with(
              ENVIRONMENT_CHECK_COMMAND
            )
          end
        end

        context 'when the environment does not exist' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when ENVIRONMENT_CHECK_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { false }
              when ENVIRONMENT_CREATE_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { true }
              else
                allow(@kernel_helper_class).to receive(:success?) { false }
              end
            end
          end

          it 'should create the environment' do
            @knife.create_environment environment: ENVIRONMENT
            expect(@kernel_helper_class).to have_received(:shell).twice
            expect(@kernel_helper_class).to have_received(:shell).with(
              ENVIRONMENT_CHECK_COMMAND
            )
            expect(@kernel_helper_class).to have_received(:shell).with(
              ENVIRONMENT_CREATE_COMMAND
            )
          end
        end

        context 'when the environment fails to create' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when ENVIRONMENT_CHECK_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { false }
              when ENVIRONMENT_CREATE_COMMAND
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { false }
              end
            end
          end

          it 'should fail' do
            expect do
              @knife.create_environment environment: ENVIRONMENT
            end.to raise_error(
              'failed to create opscode environment: env'
            )
          end
        end
      end

      describe '#bootstrap' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true
          )
        end

        context 'when the host is the bastion' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive :shell
            allow(@kernel_helper_class).to receive(:success?) { true }
          end

          it 'should bootstrap the host directly' do
            @knife.bootstrap(
              environment: ENVIRONMENT,
              bastion_hostname: 'hostname',
              cookbook: 'cookbook',
              hostname: 'hostname',
              private_key: 'private_key'
            )
            expect(@kernel_helper_class).to have_received(:shell).once
            expect(@kernel_helper_class).to have_received(:shell).with(
              BOOTSTRAP_COMMAND
            )
          end
        end

        context 'when the host is not the bastion' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive :shell
            allow(@kernel_helper_class).to receive(:success?) { true }
          end

          it 'should bootstrap the host directly' do
            @knife.bootstrap(
              environment: ENVIRONMENT,
              bastion_hostname: 'bastion',
              cookbook: 'cookbook',
              hostname: 'hostname',
              private_key: 'private_key'
            )
            expect(@kernel_helper_class).to have_received(:shell).once
            expect(@kernel_helper_class).to have_received(:shell).with(
              BOOTSTRAP_COMMAND_WITH_BASTION
            )
          end
        end

        context 'when the bootstrap command fails' do
          before(:each) do
            @kernel_helper_class = class_double(
              'Formatron::Util::KernelHelper'
            ).as_stubbed_const
            allow(@kernel_helper_class).to receive :shell
            allow(@kernel_helper_class).to receive(:success?) { false }
          end

          it 'should fail' do
            expect do
              @knife.bootstrap(
                environment: ENVIRONMENT,
                bastion_hostname: 'bastion',
                cookbook: 'cookbook',
                hostname: 'hostname',
                private_key: 'private_key'
              )
            end.to raise_error(
              'failed to bootstrap instance: hostname'
            )
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
