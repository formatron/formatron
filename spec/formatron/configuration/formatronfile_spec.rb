require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration/formatronfile'

describe Formatron::Configuration::Formatronfile do
  region = 'region'
  target = 'target1'
  config = {}
  directory = 'test/configuration'
  name = 'name'
  protect = false
  kms_key = 'kms_key'
  bucket = 'bucket'
  bootstrap_template = 'bootstrap_template'

  before(:each) do
    aws = instance_double('Formatron::AWS')
    allow(aws).to receive(:region) { region }

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

    @bootstrap_template = class_double(
      'Formatron::Configuration::Formatronfile' \
      '::CloudFormation::BootstrapTemplate'
    ).as_stubbed_const
    allow(@bootstrap_template).to receive(:json) { bootstrap_template }

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
      expect(@bootstrap_template).to have_received(:json).once.with(
        region: region,
        bucket: bucket,
        target: target,
        name: name,
        bootstrap: @bootstrap
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
