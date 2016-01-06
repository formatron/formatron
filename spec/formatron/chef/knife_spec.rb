require 'spec_helper'
require 'json'

require 'formatron/chef/knife'

GUID = 'guid'
ENVIRONMENT_CHECK_COMMAND = 'knife environment ' \
                            "show #{GUID} " \
                            '-c knife_file'
ENVIRONMENT_CREATE_COMMAND = 'knife environment create ' \
                             "#{GUID} -c " \
                             "knife_file -d '#{GUID} environment " \
                             "created by formatron'"
BOOTSTRAP_COMMAND = 'knife bootstrap hostname ' \
                    '--sudo -x ubuntu -i ec2_key -E ' \
                    "#{GUID} -r cookbook -N #{GUID} " \
                    '-c knife_file --secret-file secret_file'
BOOTSTRAP_COMMAND_WITH_BASTION = 'knife bootstrap hostname ' \
                                 '--sudo -x ubuntu -i ec2_key -E ' \
                                 "#{GUID} -r cookbook " \
                                 "-N #{GUID} " \
                                 '-c knife_file --secret-file secret_file ' \
                                 '-G ubuntu@bastion'
DELETE_NODE_COMMAND = "knife node delete #{GUID} -y -c knife_file"
DELETE_CLIENT_COMMAND = "knife client delete #{GUID} -y -c knife_file"
DELETE_ENVIRONMENT_COMMAND = "knife environment delete #{GUID} -y -c " \
                             'knife_file'
DELETE_DATA_BAG_COMMAND = 'knife data bag delete formatron name ' \
                          '-y -c knife_file'
CHECK_DATA_BAG_COMMAND = 'knife data bag show formatron -c knife_file'
CREATE_DATA_BAG_COMMAND = 'knife data bag create formatron -c knife_file'
CREATE_DATA_BAG_ITEM_COMMAND = 'knife data bag from file formatron ' \
                               'databag_file --secret-file secret_file ' \
                               '-c knife_file'

class Formatron
  # rubocop:disable Metrics/ClassLength
  class Chef
    describe Knife do
      before(:each) do
        @name = 'name'
        @configuration = {
          'configuration' => 'configuration'
        }
        @keys = instance_double 'Formatron::Chef::Keys'
        @chef_server_url = 'chef_server_url'
        @username = 'username'
        @user_key = 'user_key'
        @ec2_key = 'ec2_key'
        @databag_secret = 'databag_secret'
        allow(@keys).to receive(:user_key) { @user_key }
        @organization = 'organization'
        @organization_key = 'organization_key'
        allow(@keys).to receive(:organization_key) { @organization_key }
        allow(@keys).to receive(:ec2_key) { @ec2_key }
        @knife_tempfile = instance_double('Tempfile')
        allow(@knife_tempfile).to receive(:write)
        allow(@knife_tempfile).to receive(:close)
        allow(@knife_tempfile).to receive(:unlink)
        allow(@knife_tempfile).to receive(:path) do
          'knife_file'
        end
        @databag_secret_tempfile = instance_double('Tempfile')
        allow(@databag_secret_tempfile).to receive(:write)
        allow(@databag_secret_tempfile).to receive(:close)
        allow(@databag_secret_tempfile).to receive(:unlink)
        allow(@databag_secret_tempfile).to receive(:path) do
          'secret_file'
        end
        @databag_tempfile = instance_double('Tempfile')
        allow(@databag_tempfile).to receive(:write)
        allow(@databag_tempfile).to receive(:close)
        allow(@databag_tempfile).to receive(:unlink)
        allow(@databag_tempfile).to receive(:path) do
          'databag_file'
        end
        @tempfile_class = class_double('Tempfile').as_stubbed_const
        allow(@tempfile_class).to receive(:new).with(
          'formatron-knife-'
        ) { @knife_tempfile }
        allow(@tempfile_class).to receive(:new).with(
          'formatron-databag-secret-'
        ) { @databag_secret_tempfile }
        allow(@tempfile_class).to receive(:new).with(
          ['formatron-databag-', '.json']
        ) { @databag_tempfile }
      end

      context 'when verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        it 'should create a temporary file for the knife ' \
           'config setting the verify mode to :verify_peer' do
          expect(@knife_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^ {14}/, '')
              chef_server_url '#{@chef_server_url}'
              validation_client_name '#{@organization}-validator'
              validation_key '#{@organization_key}'
              node_name '#{@username}'
              client_key '#{@user_key}'
              verify_api_cert true
              ssl_verify_mode :verify_peer
            EOH
          ).once
          expect(@knife_tempfile).to have_received(:close).with(no_args).once
        end

        it 'should create a temporary file for the databag ' \
           'encryption secret' do
          expect(@databag_secret_tempfile).to have_received(
            :write
          ).with @databag_secret
          expect(@databag_secret_tempfile).to have_received(
            :close
          ).with no_args
        end
      end

      context 'when not verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: false,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        it 'should create a temporary file for the knife ' \
           'config setting the verify mode to :verify_none' do
          expect(@knife_tempfile).to have_received(:write).with(
            <<-EOH.gsub(/^\ {14}/, '')
              chef_server_url '#{@chef_server_url}'
              validation_client_name '#{@organization}-validator'
              validation_key '#{@organization_key}'
              node_name '#{@username}'
              client_key '#{@user_key}'
              verify_api_cert false
              ssl_verify_mode :verify_none
            EOH
          ).once
          expect(@knife_tempfile).to have_received(:close).with(no_args).once
        end

        it 'should create a temporary file for the databag ' \
           'encryption secret' do
          expect(@databag_secret_tempfile).to have_received(
            :write
          ).with @databag_secret
          expect(@databag_secret_tempfile).to have_received(
            :close
          ).with no_args
        end
      end

      describe '#unlink' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: false,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
          @knife.unlink
        end

        it 'should delete the knife config file' do
          expect(@knife_tempfile).to have_received(:unlink).with(no_args).once
        end

        it 'should delete the databag secret file' do
          expect(@databag_secret_tempfile).to have_received(
            :unlink
          ).with no_args
        end
      end

      describe '#deploy_databag' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
          expect(@databag_tempfile).to receive(
            :write
          ).with @configuration.merge(id: @name).to_json
          expect(@databag_tempfile).to receive(
            :close
          ).with no_args
          expect(@databag_tempfile).to receive(
            :unlink
          ).with no_args
        end

        context 'when the data bag already exists' do
          before :each do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              CHECK_DATA_BAG_COMMAND
            ) { true }
            allow(@shell).to receive(:exec).with(
              CREATE_DATA_BAG_ITEM_COMMAND
            ) { true }
          end

          it 'should create the data bag item' do
            @knife.deploy_databag name: @name
            expect(@shell).to have_received(:exec).with(
              CHECK_DATA_BAG_COMMAND
            )
            expect(@shell).to have_received(:exec).with(
              CREATE_DATA_BAG_ITEM_COMMAND
            )
          end

          context 'when the item fails to create' do
            before :each do
              allow(@shell).to receive(:exec).with(
                CREATE_DATA_BAG_ITEM_COMMAND
              ) { false }
            end

            it 'should fail' do
              expect do
                @knife.deploy_databag name: @name
              end.to raise_error(
                "failed to create data bag item: #{@name}"
              )
            end
          end
        end

        context 'when the data bag does not already exist' do
          before :each do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              CHECK_DATA_BAG_COMMAND
            ) { false }
            allow(@shell).to receive(:exec).with(
              CREATE_DATA_BAG_COMMAND
            ) { true }
            allow(@shell).to receive(:exec).with(
              CREATE_DATA_BAG_ITEM_COMMAND
            ) { true }
          end

          it 'should create the data bag and item' do
            @knife.deploy_databag name: @name
            expect(@shell).to have_received(:exec).with(
              CHECK_DATA_BAG_COMMAND
            )
            expect(@shell).to have_received(:exec).with(
              CREATE_DATA_BAG_COMMAND
            )
            expect(@shell).to have_received(:exec).with(
              CREATE_DATA_BAG_ITEM_COMMAND
            )
          end

          context 'when the data bag fails to create' do
            before :each do
              allow(@shell).to receive(:exec).with(
                CREATE_DATA_BAG_COMMAND
              ) { false }
            end

            it 'should fail' do
              expect do
                @knife.deploy_databag name: @name
              end.to raise_error(
                'failed to create data bag: formatron'
              )
            end
          end

          context 'when the item fails to create' do
            before :each do
              allow(@shell).to receive(:exec).with(
                CREATE_DATA_BAG_ITEM_COMMAND
              ) { false }
            end

            it 'should fail' do
              expect do
                @knife.deploy_databag name: @name
              end.to raise_error(
                "failed to create data bag item: #{@name}"
              )
            end
          end
        end
      end

      describe '#create_environment' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the environment already exists' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CHECK_COMMAND
            ) { true }
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CREATE_COMMAND
            ) { true }
          end

          it 'should do nothing' do
            @knife.create_environment environment: GUID
            expect(@shell).to have_received(:exec).once
            expect(@shell).to have_received(:exec).with(
              ENVIRONMENT_CHECK_COMMAND
            )
          end
        end

        context 'when the environment does not exist' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CHECK_COMMAND
            ) { false }
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CREATE_COMMAND
            ) { true }
          end

          it 'should create the environment' do
            @knife.create_environment environment: GUID
            expect(@shell).to have_received(:exec).twice
            expect(@shell).to have_received(:exec).with(
              ENVIRONMENT_CHECK_COMMAND
            )
            expect(@shell).to have_received(:exec).with(
              ENVIRONMENT_CREATE_COMMAND
            )
          end
        end

        context 'when the environment fails to create' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CHECK_COMMAND
            ) { false }
            allow(@shell).to receive(:exec).with(
              ENVIRONMENT_CREATE_COMMAND
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.create_environment environment: GUID
            end.to raise_error(
              "failed to create opscode environment: #{GUID}"
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
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the host is the bastion' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              BOOTSTRAP_COMMAND
            ) { true }
          end

          it 'should bootstrap the host directly' do
            @knife.bootstrap(
              guid: GUID,
              bastion_hostname: 'hostname',
              cookbook: 'cookbook',
              hostname: 'hostname'
            )
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the host is not the bastion' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              BOOTSTRAP_COMMAND_WITH_BASTION
            ) { true }
          end

          it 'should bootstrap the host directly' do
            @knife.bootstrap(
              guid: GUID,
              bastion_hostname: 'bastion',
              cookbook: 'cookbook',
              hostname: 'hostname'
            )
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the bootstrap command fails' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              BOOTSTRAP_COMMAND_WITH_BASTION
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.bootstrap(
                guid: GUID,
                bastion_hostname: 'bastion',
                cookbook: 'cookbook',
                hostname: 'hostname'
              )
            end.to raise_error(
              "failed to bootstrap instance: #{GUID}"
            )
          end
        end
      end

      describe '#delete_databag' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the delete command succeeds' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_DATA_BAG_COMMAND
            ) { true }
          end

          it 'should delete the node' do
            @knife.delete_databag name: @name
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the delete command fails' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_DATA_BAG_COMMAND
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.delete_databag name: @name
            end.to raise_error(
              "failed to delete data bag item: #{@name}"
            )
          end
        end
      end

      describe '#delete_node' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the delete command succeeds' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_NODE_COMMAND
            ) { true }
          end

          it 'should delete the node' do
            @knife.delete_node(
              node: GUID
            )
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the delete command fails' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_NODE_COMMAND
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.delete_node(
                node: GUID
              )
            end.to raise_error(
              "failed to delete node: #{GUID}"
            )
          end
        end
      end

      describe '#delete_client' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the delete command succeeds' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_CLIENT_COMMAND
            ) { true }
          end

          it 'should delete the client' do
            @knife.delete_client(
              client: GUID
            )
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the delete command fails' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_CLIENT_COMMAND
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.delete_client(
                client: GUID
              )
            end.to raise_error(
              "failed to delete client: #{GUID}"
            )
          end
        end
      end

      describe '#delete_environment' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the delete command succeeds' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_ENVIRONMENT_COMMAND
            ) { true }
          end

          it 'should delete the environment' do
            @knife.delete_environment(
              environment: GUID
            )
            expect(@shell).to have_received(:exec).once
          end
        end

        context 'when the delete command fails' do
          before(:each) do
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              DELETE_ENVIRONMENT_COMMAND
            ) { false }
          end

          it 'should fail' do
            expect do
              @knife.delete_environment(
                environment: GUID
              )
            end.to raise_error(
              "failed to delete environment: #{GUID}"
            )
          end
        end
      end

      describe '#node_exists?' do
        before(:each) do
          @knife = Knife.new(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        it 'should return false' do
          expect(@knife.node_exists?(guid: GUID)).to eql false
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
