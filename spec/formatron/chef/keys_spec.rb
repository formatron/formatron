require 'spec_helper'
require 'formatron/chef/keys'

class Formatron
  # namespacing for tests
  class Chef
    describe Keys do
      before :each do
        @aws = instance_double 'Formatron::AWS'
        @bucket = 'bucket'
        @name = 'name'
        @target = 'target'
        @directory = 'directory'
        @user_pem_path = 'user_pem_path'
        @organization_pem_path = 'organization_pem_path'
        @s3_chef_server_keys = class_double(
          'Formatron::S3::ChefServerKeys'
        ).as_stubbed_const
        allow(@s3_chef_server_keys).to receive(:get)
        allow(@s3_chef_server_keys).to receive(
          :user_pem_path
        ) { @user_pem_path }
        allow(@s3_chef_server_keys).to receive(
          :organization_pem_path
        ) { @organization_pem_path }
        allow(Dir).to receive(:mktmpdir) { @directory }
        allow(FileUtils).to receive :rm_rf
        @keys = Keys.new(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target
        )
        @keys.init
      end

      describe '#init' do
        it 'should download the Chef Server ' \
           'keys to a temporary directory' do
          expect(Dir).to have_received(:mktmpdir).once.with(
            'formatron-chef-server-keys-'
          )
          expect(@s3_chef_server_keys).to have_received(:get).once.with(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target,
            directory: @directory
          )
        end
      end

      describe '#user_key' do
        it 'should return the path to the user key' do
          expect(@keys.user_key).to eql @user_pem_path
          expect(@s3_chef_server_keys).to have_received(
            :user_pem_path
          ).once.with(directory: @directory)
        end
      end

      describe '#organization_key' do
        it 'should return the path to the organization key' do
          expect(@keys.organization_key).to eql @organization_pem_path
          expect(@s3_chef_server_keys).to have_received(
            :organization_pem_path
          ).once.with(directory: @directory)
        end
      end

      describe '#unlink' do
        it 'should clean up the temporary files' do
          @keys.unlink
          expect(FileUtils).to have_received(:rm_rf).with @directory
        end
      end
    end
  end
end
