require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap'

describe Formatron::Configuration::Formatronfile::Bootstrap do
  protect = true

  before(:each) do
    @bootstrap = Formatron::Configuration::Formatronfile::Bootstrap.new(
      protect
    )
  end

  describe '#protect' do
    it 'should return whether the configuration should be ' \
       'protected from accidental deployment, etc' do
      expect(@bootstrap.protect).to eql protect
    end
  end
end
