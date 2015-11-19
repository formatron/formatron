require 'spec_helper'

require 'formatron/cli'
require 'formatron/cli/generators/databag_secret'

describe Formatron::CLI::Generators::DatabagSecret do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::CLI::Generators::DatabagSecret
  end

  before(:each) do
    allow(Commander::Runner).to receive(:instance) do
      @singleton ||=
        Commander::Runner.new [
          'generate',
          'data',
          'bag',
          'secret',
          '-t'
        ]
    end
  end

  it 'should print a data bag secret' do
    expect(
      Formatron::Generators::Util
    ).to receive(:databag_secret).once.with(
      no_args
    )
    Test.new.run
  end
end
