require 'spec_helper'
require 'json'
require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_configuration'

describe Formatron::S3Configuration do
  target = 'target'
  kms_key = 'kms_key'
  bucket = 'bucket'
  name = 'name'
  config = {
    'param' => 'param'
  }
  key = 'key'

  before(:each) do
    @aws = instance_double 'Formatron::AWS'
    @s3_path = class_double(
      'Formatron::S3Path'
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
      Formatron::S3Configuration.deploy(
        aws: @aws,
        kms_key: kms_key,
        bucket: bucket,
        name: name,
        target: target,
        config: config
      )
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
      Formatron::S3Configuration.destroy(
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
        Formatron::S3Configuration.key(
          name: name,
          target: target
        )
      ).to eql key
    end
  end
end
