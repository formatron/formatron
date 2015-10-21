require 'spec_helper'

require 'formatron/cli'
require 'formatron/generators/bootstrap/cli'

describe Formatron::Generators::Bootstrap::CLI do
  # Test harness
  class Test < Formatron::CLI
    include Formatron::Generators::Bootstrap::CLI
  end

  directory = 'directory'
  name = 'test'
  hosted_zone_id = 'ABCDEF'

  expected_params = {
    name: name,
    hosted_zone_id: hosted_zone_id
  }

  before(:each) do
    @bootstrap = class_double(
      'Formatron::Generators::Bootstrap'
    ).as_stubbed_const
  end

  context 'with no options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['bootstrap', '-t']
      end
      @input = StringIO.new <<-EOH.gsub(/^ {8}/, '')
        #{directory}
        #{name}
        #{hosted_zone_id}
      EOH
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
    end

    after(:each) do
      puts @output.read
    end

    it 'should prompt for parameters' do
      expect(@bootstrap).to receive(:generate).once.with(
        File.expand_path('directory'),
        expected_params
      )
      Test.new.run
    end
  end

  context 'with all short form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['bootstrap',
                                              '-d', directory,
                                              '-n', name,
                                              '-z', hosted_zone_id]
      end
    end

    it 'should call generate' do
      expect(@bootstrap).to receive(:generate).once.with(
        File.expand_path('directory'),
        expected_params
      )
      Test.new.run
    end
  end
end
