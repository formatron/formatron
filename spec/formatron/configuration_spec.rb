require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration'

describe Formatron::Configuration do
  directory = 'test/configuration'
  targets = %w(target1 target2)
  target_config = {}
  protect = true

  before(:each) do
    @config = class_double(
      'Formatron::Configuration::Config'
    ).as_stubbed_const
    allow(@config).to receive(:targets) { targets }
    allow(@config).to receive(:target) { target_config }

    @formatronfile_class = class_double(
      'Formatron::Configuration::Formatronfile'
    ).as_stubbed_const
    @formatronfile = instance_double(
      'Formatron::Configuration::Formatronfile'
    )
    allow(@formatronfile_class).to receive(:new) { @formatronfile }

    @bootstrap = instance_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    )
    allow(@formatronfile).to receive(:bootstrap) { @bootstrap }
    allow(@bootstrap).to receive(:protect) { protect }

    @aws = instance_double('Formatron::AWS')

    @configuration = Formatron::Configuration.new(@aws, directory)
  end

  describe '#targets' do
    it 'should return the targets defined in the config directory' do
      expect(@configuration.targets).to eql targets
      expect(@config).to have_received(:targets).once.with directory
    end
  end

  describe '#protected?' do
    it 'should check the Formatronfile to see if ' \
       'the target should be protected' do
      expect(@configuration.protected?(targets[0])).to eql protect
      expect(@config).to have_received(:target).once.with directory, targets[0]
      expect(@formatronfile_class).to have_received(:new).once.with(
        @aws,
        targets[0],
        target_config,
        directory
      )
      expect(@formatronfile).to have_received(:bootstrap).once.with no_args
      expect(@bootstrap).to have_received(:protect).once.with no_args
    end
  end

  describe '#name' do
    skip 'it should do something' do
    end
  end

  describe '#kms_key' do
    skip 'it should do something' do
    end
  end

  describe '#bucket' do
    skip 'it should do something' do
    end
  end

  describe '#config' do
    skip 'it should do something' do
    end
  end
end
