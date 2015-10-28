require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap'

describe Formatron::Configuration::Formatronfile::Bootstrap do
  protect = true
  kms_key = 'kms_key'

  before(:each) do
    @bootstrap = Formatron::Configuration::Formatronfile::Bootstrap.new(
      protect,
      kms_key
    )
  end

  describe '#protect' do
    it 'should return whether the configuration should be ' \
       'protected from accidental deployment, etc' do
      expect(@bootstrap.protect).to eql protect
    end
  end

  describe '#kms_key' do
    it 'should return the KMS key' do
      expect(@bootstrap.kms_key).to eql kms_key
    end
  end
end
