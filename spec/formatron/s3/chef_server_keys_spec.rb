require 'spec_helper'
require 'json'
require 'formatron/aws'
require 'formatron/s3/chef_server_keys'

class Formatron
  # namespacing for tests
  module S3
    describe ChefServerCert do
      target = 'target'
      bucket = 'bucket'
      name = 'name'
      user_pem_key = 'user_pem_key'
      organization_pem_key = 'organization_pem_key'
      directory = 'directory'

      before(:each) do
        @aws = instance_double 'Formatron::AWS'
        @s3_path = class_double(
          'Formatron::S3::Path'
        ).as_stubbed_const
      end

      describe '::get' do
        it 'should download the user and organization keys from S3' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'user.pem'
          ) { user_pem_key }
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'organization.pem'
          ) { organization_pem_key }
          expect(@aws).to receive(:download_file).once.with(
            bucket: bucket,
            key: user_pem_key,
            path: File.join(directory, 'user.pem')
          )
          expect(@aws).to receive(:download_file).once.with(
            bucket: bucket,
            key: organization_pem_key,
            path: File.join(directory, 'organization.pem')
          )
          ChefServerKeys.get(
            aws: @aws,
            bucket: bucket,
            name: name,
            target: target,
            directory: directory
          )
        end
      end

      describe '::user_pem_key' do
        it 'should return the S3 key to the user key' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'user.pem'
          ) { user_pem_key }
          expect(
            ChefServerKeys.user_pem_key(
              name: name,
              target: target
            )
          ).to eql user_pem_key
        end
      end

      describe '::user_pem_path' do
        it 'should return the path to the downloaded user key' do
          expect(
            ChefServerKeys.user_pem_path(
              directory: directory
            )
          ).to eql File.join directory, 'user.pem'
        end
      end

      describe '::organization_pem_key' do
        it 'should return the S3 key to the organization key' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'organization.pem'
          ) { organization_pem_key }
          expect(
            ChefServerKeys.organization_pem_key(
              name: name,
              target: target
            )
          ).to eql organization_pem_key
        end
      end

      describe '::organization_pem_path' do
        it 'should return the path to the downloaded organization key' do
          expect(
            ChefServerKeys.organization_pem_path(
              directory: directory
            )
          ).to eql File.join directory, 'organization.pem'
        end
      end
    end
  end
end
