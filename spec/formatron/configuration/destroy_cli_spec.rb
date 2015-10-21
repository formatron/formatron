require 'spec_helper'

require 'formatron/cli'
require 'formatron/configuration/destroy_cli'

describe Formatron::Configuration::DestroyCLI do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::Configuration::DestroyCLI
  end

  credentials = 'credentials'
  directory = 'directory'
  target = 'production'
  target_index = 1

  expected_constructor_params = [
    credentials,
    directory
  ]

  expected_params = [
    target
  ]

  before(:each) do
    @configuration = instance_double('Formatron::Configuration')
    allow(@configuration).to receive(:targets) do
      %w(production test)
    end
    allow(@configuration).to receive(:protected?) do
      true
    end
  end

  context 'with no options and global defaults' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['destroy', '-t']
      end
    end

    it 'should prompt for target' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{target_index}
        yes
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Configuration
      ).to receive(:new).once.with(
        File.join(Dir.home, '.formatron/credentials.json'),
        Dir.pwd
      ) do
        @configuration
      end
      expect(@configuration).to receive(:destroy).with(
        *expected_params
      ).once
      Test.new.run
    end
  end

  context 'with no options and local defaults' do
    before(:each) do
      FileUtils.mkdir_p File.join(Dir.pwd, '.formatron')
      File.write File.join(Dir.pwd, '.formatron/credentials.json'), ''
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['destroy', '-t']
      end
    end

    it 'should prompt for target' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{target_index}
        yes
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Configuration
      ).to receive(:new).once.with(
        File.join(Dir.pwd, '.formatron/credentials.json'),
        Dir.pwd
      ) do
        @configuration
      end
      expect(@configuration).to receive(:destroy).with(
        *expected_params
      ).once
      Test.new.run
    end
  end

  context 'with all short form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'destroy',
            '-t',
            '-c', credentials,
            '-d', directory,
            target
          ]
      end
    end

    it 'should not prompt for target' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        yes
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Configuration
      ).to receive(:new).once.with(
        *expected_constructor_params
      ) do
        @configuration
      end
      expect(@configuration).to receive(:destroy).with(
        *expected_params
      ).once
      Test.new.run
    end
  end

  context 'with all long form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'destroy',
            '-t',
            '--credentials', credentials,
            '--directory', directory,
            target
          ]
      end
    end

    it 'should not prompt for target' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        yes
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Configuration
      ).to receive(:new).once.with(
        *expected_constructor_params
      ) do
        @configuration
      end
      expect(@configuration).to receive(:destroy).with(
        *expected_params
      ).once
      Test.new.run
    end
  end
end
