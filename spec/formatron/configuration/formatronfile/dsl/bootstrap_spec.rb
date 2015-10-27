require 'spec_helper'
require 'formatron/configuration/formatronfile/dsl/bootstrap'

describe Formatron::Configuration::Formatronfile::DSL::Bootstrap do
  include FakeFS::SpecHelpers

  block = proc do
    protect true
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
end
