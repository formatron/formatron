require 'spec_helper'
require 'json'
require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_configuration'

describe Formatron::S3Configuration do
  target = 'target'
  kms_key = 'kms_key'
  bucket = 'bucket'
  config = {
    'param' => 'param'
  }
  key = 'key'

  before(:each) do
    @aws = instance_double 'Formatron::AWS'
    @configuration = instance_double 'Formatron::Configuration'
    @s3_path = class_double(
      'Formatron::S3Path'
    ).as_stubbed_const
  end

  describe '::deploy' do
    it 'should upload the JSON configuration to S3' do
      expect(@s3_path).to receive(:path).once.with(
        configuration: @configuration,
        target: target,
        sub_path: 'config.json'
      ) { key }
      expect(@configuration).to receive(:kms_key).once.with(
        target
      ) { kms_key }
      expect(@configuration).to receive(:bucket).once.with(
        target
      ) { bucket }
      expect(@configuration).to receive(:config).once.with(
        target
      ) { config }
      expect(@aws).to receive(:upload).once.with(
        kms_key,
        bucket,
        key,
        config.to_json
      )
      Formatron::S3Configuration.deploy(
        @aws,
        @configuration,
        target
      )
    end
  end

  describe '::destroy' do
    it 'should delete the JSON configuration from S3' do
      expect(@s3_path).to receive(:path).once.with(
        configuration: @configuration,
        target: target,
        sub_path: 'config.json'
      ) { key }
      expect(@configuration).to receive(:bucket).once.with(
        target
      ) { bucket }
      expect(@aws).to receive(:delete).once.with(
        bucket,
        key
      )
      Formatron::S3Configuration.destroy(
        @aws,
        @configuration,
        target
      )
    end
  end
end
