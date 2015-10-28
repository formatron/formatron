require 'spec_helper'
require 'formatron/configuration/formatronfile/dsl/bootstrap'

describe Formatron::Configuration::Formatronfile::DSL::Bootstrap do
  include FakeFS::SpecHelpers

  block = proc do
    protect true
    kms_key 'kms_key'
  end
  target = 'target'
  config = {}

  before(:each) do
    @bootstrap = Formatron::Configuration::Formatronfile::DSL::Bootstrap.new(
      target,
      config,
      block
    )
  end

  describe '#protect' do
    it 'should set the protect property' do
      expect(@bootstrap.protect).to eql true
    end
  end

  describe '#kms_key' do
    it 'should set the kms_key property' do
      expect(@bootstrap.kms_key).to eql 'kms_key'
    end
  end
end
