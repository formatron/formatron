require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration/formatronfile'

describe Formatron::Configuration::Formatronfile do
  region = 'region'
  target = 'target1'
  config = {}
  config_key = 'config_key'
  directory = 'test/configuration'
  name = 'name'
  protect = false
  kms_key = 'kms_key'
  bucket = 'bucket'
  bootstrap_template = 'bootstrap_template'
  hosted_zone_id = 'hosted_zone_id'
  hosted_zone_name = 'hosted_zone_name'

  before(:each) do
    aws = instance_double('Formatron::AWS')
    allow(aws).to receive(:region) { region }
    expect(aws).to receive(:hosted_zone_name).once.with(
      hosted_zone_id
    ) { hosted_zone_name }

    dsl_class = class_double(
      'Formatron::Configuration::Formatronfile::DSL'
    ).as_stubbed_const
    dsl = instance_double(
      'Formatron::Configuration::Formatronfile::DSL'
    )
    expect(dsl_class).to receive(:new).once.with(
      aws: aws,
      config: config,
      target: target,
      file: File.join(directory, 'Formatronfile')
    ) { dsl }
    allow(dsl).to receive(:name) { name }
    allow(dsl).to receive(:bucket) { bucket }

    @bootstrap = instance_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    )
    allow(dsl).to receive(:bootstrap) { @bootstrap }

    allow(@bootstrap).to receive(:protect) { protect }
    allow(@bootstrap).to receive(:kms_key) { kms_key }
    allow(@bootstrap).to receive(:hosted_zone_id) { hosted_zone_id }

    @bootstrap_template = class_double(
      'Formatron::Configuration::Formatronfile' \
      '::CloudFormation::BootstrapTemplate'
    ).as_stubbed_const
    allow(@bootstrap_template).to receive(:json) { bootstrap_template }

    @s3_configuration = class_double(
      'Formatron::S3Configuration'
    ).as_stubbed_const
    allow(@s3_configuration).to receive(:key) { config_key }

    @formatronfile = Formatron::Configuration::Formatronfile.new(
      aws: aws,
      config: config,
      target: target,
      directory: directory
    )
  end

  describe '#cloud_formation_template' do
    it 'should return the CloudFormation template JSON' do
      expect(@formatronfile.cloud_formation_template).to eql bootstrap_template
      expect(@s3_configuration).to have_received(:key).once.with(
        name: name,
        target: target
      )
      expect(@bootstrap_template).to have_received(:json).once.with(
        region: region,
        hosted_zone_id: hosted_zone_id,
        hosted_zone_name: hosted_zone_name,
        bootstrap: @bootstrap,
        bucket: bucket,
        config_key: config_key
      )
    end
  end

  describe '#target' do
    it 'should return the target of the configuration' do
      expect(@formatronfile.target).to eql target
    end
  end

  describe '#name' do
    it 'should return the name of the configuration' do
      expect(@formatronfile.name).to eql name
    end
  end

  describe '#bucket' do
    it 'should return the S3 bucket for the configuration' do
      expect(@formatronfile.bucket).to eql bucket
    end
  end

  describe '#hosted_zone_name' do
    it 'should return the Route53 public hosted ' \
       'zone name of the configuration' do
      expect(@formatronfile.hosted_zone_name).to eql hosted_zone_name
    end
  end

  describe '#hosted_zone_id' do
    it 'should return the Route53 public hosted ' \
       'zone ID of the configuration' do
      expect(@formatronfile.hosted_zone_id).to eql hosted_zone_id
    end
  end

  describe '#protected?' do
    it 'should return whether the configuration should be protected' do
      expect(@formatronfile.protected?).to eql protect
    end
  end

  describe '#kms_key' do
    it 'should return the KMS key for the configuration' do
      expect(@formatronfile.kms_key).to eql kms_key
    end
  end
end
