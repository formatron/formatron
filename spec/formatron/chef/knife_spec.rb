require 'spec_helper'
require 'json'

require 'formatron/chef/knife'

GUID = 'guid'
ENVIRONMENT_CHECK_COMMAND = 'knife environment ' \
                            "show #{GUID} " \
                            '-c directory/knife.rb'
ENVIRONMENT_CREATE_COMMAND = 'knife environment create ' \
                             "#{GUID} -c " \
                             "directory/knife.rb -d '#{GUID} environment " \
                             "created by formatron'"
BOOTSTRAP_COMMAND = 'knife bootstrap hostname ' \
                    '--sudo -x ubuntu -i ec2_key -E ' \
                    "#{GUID} -r cookbook -N #{GUID} " \
                    '-c directory/knife.rb ' \
                    '--secret-file directory/databag_secret'
BOOTSTRAP_COMMAND_WITH_WINDOWS = 'knife bootstrap windows winrm hostname ' \
                    "-x administrator_name -P 'administrator_password' -E " \
                    "#{GUID} -r cookbook -N #{GUID} " \
                    '-c directory/knife.rb ' \
                    '--secret-file directory/databag_secret'
BOOTSTRAP_COMMAND_WITH_BASTION = 'knife bootstrap hostname ' \
                                 '--sudo -x ubuntu -i ec2_key -E ' \
                                 "#{GUID} -r cookbook " \
                                 "-N #{GUID} " \
                                 '-c directory/knife.rb ' \
                                 '--secret-file directory/databag_secret ' \
                                 '-G ubuntu@bastion'
DELETE_NODE_COMMAND = "knife node delete #{GUID} -y -c directory/knife.rb"
DELETE_CLIENT_COMMAND = "knife client delete #{GUID} -y -c directory/knife.rb"
DELETE_ENVIRONMENT_COMMAND = "knife environment delete #{GUID} -y -c " \
                             'directory/knife.rb'
DELETE_DATA_BAG_COMMAND = 'knife data bag delete formatron name ' \
                          '-y -c directory/knife.rb'
CHECK_DATA_BAG_COMMAND = 'knife data bag show formatron -c directory/knife.rb'
CREATE_DATA_BAG_COMMAND = 'knife data bag create formatron ' \
                          '-c directory/knife.rb'
CREATE_DATA_BAG_ITEM_COMMAND = 'knife data bag from file formatron ' \
                               'directory/databag/name.json --secret-file ' \
                               'directory/databag_secret ' \
                               '-c directory/knife.rb'
SHOW_NODE_COMMAND = "knife node show #{GUID} -c directory/knife.rb"

class Formatron
  # rubocop:disable Metrics/ClassLength
  class Chef
    describe Knife do
      before(:each) do
        @directory = 'directory'
        @config_file = File.join @directory, 'knife.rb'
        @databag_secret_file = File.join @directory, 'databag_secret'
        @databag_directory = File.join @directory, 'databag'
        @name = 'name'
        @databag_file = File.join @databag_directory, "#{@name}.json"
        @configuration = {
          'configuration' => 'configuration'
        }
        @keys = instance_double 'Formatron::Chef::Keys'
        @chef_server_url = 'chef_server_url'
        @administrator_name = 'administrator_name'
        @administrator_password = 'administrator_password'
        @username = 'username'
        @user_key = 'user_key'
        @ec2_key = 'ec2_key'
        @databag_secret = 'databag_secret'
        allow(@keys).to receive(:user_key) { @user_key }
        @organization = 'organization'
        @organization_key = 'organization_key'
        allow(@keys).to receive(:organization_key) { @organization_key }
        allow(@keys).to receive(:ec2_key) { @ec2_key }
        allow(File).to receive(:write)
        allow(FileUtils).to receive(:mkdir_p)
      end

      context 'when verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        it 'should create a file for the knife ' \
           'config setting the verify mode to :verify_peer' do
          expect(File).to have_received(:write).with(
            @config_file,
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
        end

        it 'should create a file for the databag ' \
           'encryption secret' do
          expect(File).to have_received(
            :write
          ).with @databag_secret_file, @databag_secret
        end

        it 'should create a directory for the databag items' do
          expect(FileUtils).to have_received(
            :mkdir_p
          ).with @databag_directory
        end
      end

      context 'when not verifying SSL certs' do
        before(:each) do
          @knife = Knife.new(
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: false,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        it 'should create a file for the knife ' \
           'config setting the verify mode to :verify_none' do
          expect(File).to have_received(:write).with(
            @config_file,
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
        end

        it 'should create a file for the databag ' \
           'encryption secret' do
          expect(File).to have_received(
            :write
          ).with @databag_secret_file, @databag_secret
        end

        it 'should create a directory for the databag items' do
          expect(FileUtils).to have_received(
            :mkdir_p
          ).with @databag_directory
        end
      end

      describe '#deploy_databag' do
        before(:each) do
          @knife = Knife.new(
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
          expect(File).to receive(:write).with(
            @databag_file,
            @configuration.merge(id: @name).to_json
          )
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
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
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
          @os = 'os'
          @knife = Knife.new(
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the host is windows' do
          before(:each) do
            @os = 'windows'
            @shell = class_double(
              'Formatron::Util::Shell'
            ).as_stubbed_const
            allow(@shell).to receive(:exec).with(
              BOOTSTRAP_COMMAND_WITH_WINDOWS
            ) { true }
          end

          it 'should bootstrap the host directly' do
            @knife.bootstrap(
              os: @os,
              guid: GUID,
              bastion_hostname: 'bastion',
              cookbook: 'cookbook',
              hostname: 'hostname'
            )
            expect(@shell).to have_received(:exec).once
          end

          context 'when the bootstrap command fails' do
            before(:each) do
              @shell = class_double(
                'Formatron::Util::Shell'
              ).as_stubbed_const
              allow(@shell).to receive(:exec).with(
                BOOTSTRAP_COMMAND_WITH_WINDOWS
              ) { false }
            end

            it 'should fail' do
              expect do
                @knife.bootstrap(
                  os: @os,
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
              os: @os,
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
              os: @os,
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
                os: @os,
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
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
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
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
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
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
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
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
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
          @shell = class_double(
            'Formatron::Util::Shell'
          ).as_stubbed_const
          @knife = Knife.new(
            directory: @directory,
            keys: @keys,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: true,
            databag_secret: @databag_secret,
            configuration: @configuration
          )
          @knife.init
        end

        context 'when the show command succeeds' do
          before(:each) do
            expect(@shell).to receive(:exec).with(
              SHOW_NODE_COMMAND
            ) { true }
          end

          it 'should return true' do
            expect(@knife.node_exists?(guid: GUID)).to eql true
          end
        end

        context 'when the show command fails' do
          before(:each) do
            expect(@shell).to receive(:exec).with(
              SHOW_NODE_COMMAND
            ) { false }
          end

          it 'should return false' do
            expect(@knife.node_exists?(guid: GUID)).to eql false
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
