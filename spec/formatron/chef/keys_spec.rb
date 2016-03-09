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
        @guid = 'guid'
        @ec2_key = 'ec2_key'
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
        allow(File).to receive :write
        allow(File).to receive :chmod
        @keys = Keys.new(
          directory: @directory,
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          guid: @guid,
          ec2_key: @ec2_key
        )
        @keys.init
      end

      describe '#init' do
        it 'should download the Chef Server ' \
           'keys to the chef server directory' do
          expect(@s3_chef_server_keys).to have_received(:get).once.with(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target,
            guid: @guid,
            directory: @directory
          )
        end

        it 'should write the EC2 private key file' do
          expect(File).to have_received(:write).with(
            File.join(@directory, 'ec2_key'),
            @ec2_key
          )
          expect(File).to have_received(:chmod).with(
            0600,
            File.join(@directory, 'ec2_key')
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

      describe '#ec2_key' do
        it 'should return the path to the EC2 key' do
          expect(@keys.ec2_key).to eql File.join @directory, 'ec2_key'
        end
      end
    end
  end
end
