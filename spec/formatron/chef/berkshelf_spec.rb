require 'spec_helper'
require 'formatron/chef/berkshelf'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module Chef
    describe Berkshelf do
      before(:each) do
        @config = 'config'
        @tempfile = instance_double('Tempfile')
        allow(@tempfile).to receive(:write)
        allow(@tempfile).to receive(:close)
        allow(@tempfile).to receive(:path) { @config }
        @tempfile_class = class_double('Tempfile').as_stubbed_const
        allow(@tempfile_class).to receive(:new) { @tempfile }
        @keys = instance_double 'Formatron::Chef::Keys'
        @chef_server_url = 'chef_server_url'
        @username = 'username'
        @user_key = 'user_key'
        allow(@keys).to receive(:user_key) { @user_key }
        @ssl_verify = 'ssl_verify'
        @berkshelf = Berkshelf.new(
          keys: @keys,
          chef_server_url: @chef_server_url,
          username: @username,
          ssl_verify: @ssl_verify
        )
      end

      it 'should create a config file' do
        expect(@tempfile_class).to have_received(:new).once.with(
          'formatron-berkshelf-'
        )
        expect(@tempfile).to have_received(:write).once.with(
          <<-EOH.gsub(/^ {12}/, '')
            {
              "chef": {
                "chef_server_url": "#{@chef_server_url}",
                "node_name": "#{@username}",
                "client_key": "#{@user_key}"
              },
              "ssl": {
                "verify": #{@ssl_verify}
              }
            }
          EOH
        )
        expect(@tempfile).to have_received :close
      end

      describe '#upload' do
        before :each do
          @cookbook = 'cookbook'
          @environment = 'environment'
          @kernel_helper_class = class_double(
            'Formatron::Util::KernelHelper'
          ).as_stubbed_const
        end

        context 'when the berks install fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when "chef exec berks install -b #{@cookbook}/Berksfile"
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect do
              @berkshelf.upload(
                cookbook: @cookbook, environment: @environment
              )
            end.to raise_error(
              'failed to download cookbooks for opscode ' \
              "environment: #{@environment}"
            )
          end
        end

        context 'when the berks upload fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when "chef exec berks upload -c #{@config} " \
                   "-b #{@cookbook}/Berksfile"
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect do
              @berkshelf.upload(
                cookbook: @cookbook, environment: @environment
              )
            end.to raise_error(
              'failed to upload cookbooks for opscode ' \
              "environment: #{@environment}"
            )
          end
        end

        context 'when the berks apply fails' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell) do |command|
              case command
              when "chef exec berks apply #{@environment} -c #{@config} " \
                   "-b #{@cookbook}/Berksfile.lock"
                allow(@kernel_helper_class).to receive(:success?) { false }
              else
                allow(@kernel_helper_class).to receive(:success?) { true }
              end
            end
          end

          it 'should fail' do
            expect do
              @berkshelf.upload(
                cookbook: @cookbook, environment: @environment
              )
            end.to raise_error(
              'failed to apply cookbooks to opscode ' \
              "environment: #{@environment}"
            )
          end
        end

        context 'when all the berks commands succeed' do
          before(:each) do
            allow(@kernel_helper_class).to receive(:shell)
            allow(@kernel_helper_class).to receive(:success?) { true }
            @berkshelf.upload(
              cookbook: @cookbook, environment: @environment
            )
          end

          it 'should install cookbooks' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              "chef exec berks install -b #{@cookbook}/Berksfile"
            ).once
          end

          it 'should upload cookbooks' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              "chef exec berks upload -c #{@config} " \
              "-b #{@cookbook}/Berksfile"
            ).once
          end

          it 'should apply cookbooks to the environment' do
            expect(@kernel_helper_class).to have_received(:shell).with(
              "chef exec berks apply #{@environment} -c #{@config} " \
              "-b #{@cookbook}/Berksfile.lock"
            ).once
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
