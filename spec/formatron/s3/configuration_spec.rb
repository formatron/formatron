require 'spec_helper'
require 'json'
require 'formatron/aws'
require 'formatron/s3/configuration'

class Formatron
  # namespacing for tests
  module S3
    describe Configuration do
      target = 'target'
      kms_key = 'kms_key'
      bucket = 'bucket'
      name = 'name'
      config = {
        'param' => 'param'
      }
      key = 'key'

      before(:each) do
        stub_const 'Formatron::LOG', Logger.new('/dev/null')
        @aws = instance_double 'Formatron::AWS'
        @s3_path = class_double(
          'Formatron::S3::Path'
        ).as_stubbed_const
      end

      describe '::deploy' do
        it 'should upload the JSON configuration to S3' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'config.json'
          ) { key }
          expect(@aws).to receive(:upload_file).once.with(
            kms_key: kms_key,
            bucket: bucket,
            key: key,
            content: "#{JSON.pretty_generate(config)}\n"
          )
          Configuration.deploy(
            aws: @aws,
            kms_key: kms_key,
            bucket: bucket,
            name: name,
            target: target,
            config: config
          )
        end
      end

      describe '::get' do
        it 'should get the JSON configuration from S3' do
          content = 'content'
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'config.json'
          ) { key }
          expect(@aws).to receive(:get_file).once.with(
            bucket: bucket,
            key: key
          ) { content }
          expect(
            Configuration.get(
              aws: @aws,
              bucket: bucket,
              name: name,
              target: target
            )
          ).to eql content
        end
      end

      describe '::destroy' do
        it 'should delete the JSON configuration from S3' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'config.json'
          ) { key }
          expect(@aws).to receive(:delete_file).once.with(
            bucket: bucket,
            key: key
          )
          Configuration.destroy(
            aws: @aws,
            bucket: bucket,
            name: name,
            target: target
          )
        end
      end

      describe '::key' do
        it 'should return the S3 key to the config file' do
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'config.json'
          ) { key }
          expect(
            Configuration.key(
              name: name,
              target: target
            )
          ).to eql key
        end
      end
    end
  end
end
