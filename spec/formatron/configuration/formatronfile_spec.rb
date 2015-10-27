require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration/formatronfile'

describe Formatron::Configuration::Formatronfile do
  target = 'target1'
  config = {}
  directory = 'test/configuration'

  before(:each) do
    aws = instance_double('Formatron::AWS')

    bootstrap_block = proc do
      'bootstrap'
    end

    dsl_class = class_double(
      'Formatron::DSL'
    ).as_stubbed_const
    dsl = instance_double(
      'Formatron::DSL'
    )
    expect(dsl_class).to receive(:new).once.with(
      target,
      config,
      File.join(directory, 'Formatronfile')
    ) { dsl }
    allow(dsl).to receive(:bootstrap) { bootstrap_block }

    dsl_bootstrap_class = class_double(
      'Formatron::DSL::Bootstrap'
    ).as_stubbed_const
    dsl_bootstrap = instance_double(
      'Formatron::DSL::Bootstrap'
    )
    expect(dsl_bootstrap_class).to receive(:new).once.with(
      target,
      config,
      bootstrap_block
    ) { dsl_bootstrap }
    expect(dsl_bootstrap).to receive(:protect).once.with(
      no_args
    ) { false }

    bootstrap_class = class_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    ).as_stubbed_const
    @bootstrap = instance_double(
      'Formatron::Configuration::Formatronfile::Bootstrap'
    )
    expect(bootstrap_class).to receive(:new).once.with(
      false
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
end
