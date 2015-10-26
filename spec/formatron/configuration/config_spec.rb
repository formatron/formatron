require 'spec_helper'
require 'formatron/configuration/config'

describe Formatron::Configuration::Config do
  directory = 'test/configuration'

  before(:each) do
    @config = Formatron::Configuration::Config.new(
      directory
    )
  end

  describe('::new') do
    skip 'should do something' do
    end
  end

  describe '#targets' do
    it 'should return the targets defined in the config directory' do
    end
  end
end
