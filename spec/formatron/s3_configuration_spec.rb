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

  before(:each) do
    @aws = instance_double 'Formatron::AWS'
    @configuration = instance_double 'Formatron::Configuration'
  end

  describe '::deploy' do
    it 'should upload the JSON configuration to S3' do
      expect(@configuration).to receive(:name).once.with(
        target
      ) { name }
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
        File.join(target, name, 'config.json'),
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
    skip 'should do something' do
    end
  end
end
