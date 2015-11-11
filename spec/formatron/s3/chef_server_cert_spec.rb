require 'spec_helper'
require 'json'
require 'formatron/aws'
require 'formatron/s3/chef_server_cert'

class Formatron
  # namespacing for tests
  # rubocop:disable Metrics/ModuleLength
  module S3
    describe ChefServerCert do
      target = 'target'
      kms_key = 'kms_key'
      bucket = 'bucket'
      name = 'name'
      guid = 'guid'
      cert = 'cert'
      key = 'key'
      cert_key = 'cert_key'
      key_key = 'key_key'

      before(:each) do
        @aws = instance_double 'Formatron::AWS'
        @s3_path = class_double(
          'Formatron::S3::Path'
        ).as_stubbed_const
      end

      describe '::deploy' do
        it 'should upload the Chef Server SSL certificate and key to S3' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.cert"
          ) { cert_key }
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.key"
          ) { key_key }
          expect(@aws).to receive(:upload_file).once.with(
            kms_key: kms_key,
            bucket: bucket,
            key: cert_key,
            content: cert
          )
          expect(@aws).to receive(:upload_file).once.with(
            kms_key: kms_key,
            bucket: bucket,
            key: key_key,
            content: key
          )
          ChefServerCert.deploy(
            aws: @aws,
            kms_key: kms_key,
            bucket: bucket,
            name: name,
            target: target,
            guid: guid,
            cert: cert,
            key: key
          )
        end
      end

      describe '::destroy' do
        it 'should delete the SSL certificate and key from S3' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.cert"
          ) { cert_key }
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.key"
          ) { key_key }
          expect(@aws).to receive(:delete_file).once.with(
            bucket: bucket,
            key: cert_key
          )
          expect(@aws).to receive(:delete_file).once.with(
            bucket: bucket,
            key: key_key
          )
          ChefServerCert.destroy(
            aws: @aws,
            bucket: bucket,
            name: name,
            target: target,
            guid: guid
          )
        end
      end

      describe '::cert_key' do
        it 'should return the S3 key to the SSL certificate file' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.cert"
          ) { cert_key }
          expect(
            ChefServerCert.cert_key(
              name: name,
              target: target,
              guid: guid
            )
          ).to eql cert_key
        end
      end

      describe '::key_key' do
        it 'should return the S3 key to the SSL key file' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: "#{guid}/ssl.key"
          ) { key_key }
          expect(
            ChefServerCert.key_key(
              name: name,
              target: target,
              guid: guid
            )
          ).to eql key_key
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
