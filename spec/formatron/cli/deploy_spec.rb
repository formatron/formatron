require 'spec_helper'

require 'formatron/cli'
require 'formatron/cli/deploy'

describe Formatron::CLI::Deploy do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::CLI::Deploy
  end

  credentials = 'credentials'
  directory = 'directory'
  target = 'production'
  target_index = 1

  expected_constructor_params = {
    credentials: credentials,
    directory: directory,
    target: target
  }

  before(:each) do
    @formatron = instance_double('Formatron')
    allow(Formatron::Config).to receive(:targets) do
      %w(production test)
    end
    allow(@formatron).to receive(:protected?) do
      true
    end
  end

  context 'with no options and global defaults' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['deploy', '-t']
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
      expect(Formatron::Config).to receive(:targets).once.with(
        directory: Dir.pwd
      )
      expect(
        Formatron
      ).to receive(:new).once.with(
        credentials: File.join(Dir.home, '.formatron/credentials.json'),
        directory: Dir.pwd,
        target: target
      ) do
        @formatron
      end
      expect(@formatron).to receive(:deploy).with(
        no_args
      ).once
      Test.new.run
    end
  end

  context 'with no options and local defaults' do
    before(:each) do
      FileUtils.mkdir_p File.join(Dir.pwd, '.formatron')
      File.write File.join(Dir.pwd, '.formatron/credentials.json'), ''
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||= Commander::Runner.new ['deploy', '-t']
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
      expect(Formatron::Config).to receive(:targets).once.with(
        directory: Dir.pwd
      )
      expect(
        Formatron
      ).to receive(:new).once.with(
        credentials: File.join(Dir.pwd, '.formatron/credentials.json'),
        directory: Dir.pwd,
        target: target
      ) do
        @formatron
      end
      expect(@formatron).to receive(:deploy).with(
        no_args
      ).once
      Test.new.run
    end
  end

  context 'with all short form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'deploy',
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
      expect(Formatron::Config).to_not receive :targets
      expect(
        Formatron
      ).to receive(:new).once.with(
        expected_constructor_params
      ) do
        @formatron
      end
      expect(@formatron).to receive(:deploy).with(
        no_args
      ).once
      Test.new.run
    end
  end

  context 'with all long form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'deploy',
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
      expect(Formatron::Config).to_not receive :targets
      expect(
        Formatron
      ).to receive(:new).once.with(
        expected_constructor_params
      ) do
        @formatron
      end
      expect(@formatron).to receive(:deploy).with(
        no_args
      ).once
      Test.new.run
    end
  end
end
