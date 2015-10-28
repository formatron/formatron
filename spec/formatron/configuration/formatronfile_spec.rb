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

  before(:each) do
    aws = instance_double('Formatron::AWS')

    bootstrap_block = proc do
      'bootstrap'
    end

    dsl_class = class_double(
      'Formatron::Configuration::Formatronfile::DSL'
    ).as_stubbed_const
    dsl = instance_double(
      'Formatron::Configuration::Formatronfile::DSL'
    )
    expect(dsl_class).to receive(:new).once.with(
      target,
      config,
      File.join(directory, 'Formatronfile')
    ) { dsl }
    allow(dsl).to receive(:bootstrap) { bootstrap_block }
    allow(dsl).to receive(:name) { name }
    allow(dsl).to receive(:bucket) { bucket }

    dsl_bootstrap_class = class_double(
      'Formatron::Configuration::Formatronfile::DSL::Bootstrap'
    ).as_stubbed_const
    dsl_bootstrap = instance_double(
      'Formatron::Configuration::Formatronfile::DSL::Bootstrap'
    )
    expect(dsl_bootstrap_class).to receive(:new).once.with(
      target,
      config,
      name,
      bucket,
      bootstrap_block
    ) { dsl_bootstrap }
    expect(dsl_bootstrap).to receive(:protect).once.with(
      no_args
    ) { protect }
    expect(dsl_bootstrap).to receive(:kms_key).once.with(
      no_args
    ) { kms_key }

    bootstrap_class = class_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    ).as_stubbed_const
    @bootstrap = instance_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    )
    expect(bootstrap_class).to receive(:new).once.with(
      protect,
      kms_key
    ) { @bootstrap }

    @formatronfile = Formatron::Configuration::Formatronfile.new(
      aws,
      target,
      config,
      directory
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
end
