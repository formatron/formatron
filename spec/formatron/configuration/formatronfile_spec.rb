require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration/formatronfile'

describe Formatron::Configuration::Formatronfile do
  target = 'target1'
  config = {}
  directory = 'test/configuration'
  name = 'name'
  protect = false
  kms_key = 'kms_key'
  bucket = 'bucket'
  cloud_formation_template = 'cloud_formation_template'

  before(:each) do
    aws = instance_double('Formatron::AWS')

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

    expect(@bootstrap).to receive(:protect).once.with(
      no_args
    ) { protect }
    expect(@bootstrap).to receive(:kms_key).once.with(
      no_args
    ) { kms_key }

    @cloud_formation = class_double(
      'Formatron::Configuration::Formatronfile::CloudFormation'
    ).as_stubbed_const
    allow(@cloud_formation).to receive(:template) { cloud_formation_template }

    @formatronfile = Formatron::Configuration::Formatronfile.new(
      aws: aws,
      config: config,
      target: target,
      directory: directory
    )

    expect(@cloud_formation).to have_received(:template).once.with(
      @formatronfile
    )
  end

  describe '#bootstrap' do
    it 'should return the bootstrap configuration' do
      expect(@formatronfile.bootstrap).to eql @bootstrap
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

  describe '#cloud_formation_template' do
    it 'should return the CloudFormation template for the configuration' do
      expect(
        @formatronfile.cloud_formation_template
      ).to eql cloud_formation_template
    end
  end
end
