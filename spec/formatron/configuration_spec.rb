require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration'

describe Formatron::Configuration do
  directory = 'test/configuration'

  before(:each) do
    @config_class = class_double(
      'Formatron::Configuration::Config'
    ).as_stubbed_const
    @config = instance_double('Formatron::Configuration::Config')
    allow(@config_class).to receive(:new) { @config }

    @aws = instance_double('Formatron::AWS')

    @configuration = Formatron::Configuration.new(@aws, directory)
  end

  describe('::new') do
    it 'should create a Config instance' do
      expect(@config_class).to have_received(:new).once.with(
        directory
      )
    end
  end

  describe '#targets' do
    it 'should return the targets defined in the config directory' do
    end
  end

  describe '#protected?' do
    skip 'should do something' do
    end
  end
end
