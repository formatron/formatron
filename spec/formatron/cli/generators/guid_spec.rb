require 'spec_helper'

require 'formatron/cli'
require 'formatron/cli/generators/guid'

describe Formatron::CLI::Generators::GUID do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::CLI::Generators::GUID
  end

  before(:each) do
    allow(Commander::Runner).to receive(:instance) do
      @singleton ||=
        Commander::Runner.new [
          'generate',
          'guid',
          '-t'
        ]
    end
  end

  it 'should print a GUID' do
    expect(
      Formatron::Generators::Util
    ).to receive(:guid).once.with(
      no_args
    )
    Test.new.run
  end
end
