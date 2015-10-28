require 'spec_helper'
require 'formatron/configuration/formatronfile/dsl/bootstrap'

describe Formatron::Configuration::Formatronfile::DSL::Bootstrap do
  include FakeFS::SpecHelpers

  block = proc do
    protect true
    kms_key "#{target}-#{config['kms_key']}-#{name}-#{bucket}"
  end
  target = 'target'
  config = {
    'kms_key' => 'kms_key'
  }
  name = 'name'
  bucket = 'bucket'

  before(:each) do
    @bootstrap = Formatron::Configuration::Formatronfile::DSL::Bootstrap.new(
      target,
      config,
      name,
      bucket,
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
      expect(@bootstrap.kms_key).to eql(
        "#{target}-#{config['kms_key']}-#{name}-#{bucket}"
      )
    end
  end
end
