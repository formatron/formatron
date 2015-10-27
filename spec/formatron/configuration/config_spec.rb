require 'spec_helper'
require 'formatron/configuration/config'

describe Formatron::Configuration::Config do
  include FakeFS::SpecHelpers

  directory = 'test/configuration'
  targets = %w(target1 target2 target3)

  before(:each) do
    FileUtils.mkdir_p File.join(directory, 'config', '_default')
    targets.each do |target|
      FileUtils.mkdir_p File.join(directory, 'config', target)
    end
  end

  describe '::targets' do
    it 'should return the targets defined in the config directory' do
      expect(Formatron::Configuration::Config.targets(directory)).to eql(
        targets
      )
    end
  end

  describe '::target' do
    skip 'should return the merged target configuration ' \
         'in the config directory' do
    end
  end
end
