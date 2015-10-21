require 'spec_helper'

require 'formatron/cli'
require 'formatron/generators/instance/cli'

describe Formatron::Generators::Instance::CLI do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::Generators::Instance::CLI
  end

  directory = 'directory'
  name = 'test'
  bootstrap_configuration = 'bootstrap_configuration'

  expected_params = {
    name: name,
    bootstrap_configuration: bootstrap_configuration
  }

  before(:each) do
    lib = File.expand_path(
      File.join(
        File.dirname(File.expand_path(__FILE__)),
        '../../../../lib'
      )
    )
    FakeFS::FileSystem.clone lib
  end

  context 'with no options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['instance', '-t']
      end
    end

    it 'should prompt for parameters' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{directory}
        #{name}
        #{bootstrap_configuration}
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Instance).to receive(:generate).once.with(
        directory,
        expected_params
      ).and_call_original
      Test.new.run
    end
  end

  context 'with all short form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'instance',
            '-t',
            '-d', directory,
            '-n', name,
            '-b', bootstrap_configuration
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Instance).to receive(:generate).once.with(
        directory,
        expected_params
      )
      Test.new.run
    end
  end

  context 'with all long form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'instance',
            '-t',
            '--directory', directory,
            '--name', name,
            '--bootstrap-configuration', bootstrap_configuration
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Instance).to receive(:generate).once.with(
        directory,
        expected_params
      )
      Test.new.run
    end
  end
end
