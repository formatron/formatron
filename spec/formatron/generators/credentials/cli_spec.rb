require 'spec_helper'

require 'formatron/cli'
require 'formatron/generators/credentials/cli'

describe Formatron::Generators::Credentials::CLI do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::Generators::Credentials::CLI
  end

  credentials = 'credentials'
  region = 'eu-west-1'
  region_index = 4
  access_key_id = 'access_key_id'
  secret_access_key = 'secret_access_key'

  expected_params = [
    credentials,
    region,
    access_key_id,
    secret_access_key
  ]

  context 'with no options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'credentials',
            '-t'
          ]
      end
    end

    it 'should prompt for parameters' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{credentials}
        #{region_index}
        #{access_key_id}
        #{secret_access_key}
      EOH
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Generators::Credentials
      ).to receive(:generate).once.with(
        *expected_params
      ).and_call_original
      Test.new.run
    end
  end

  context 'with all short form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'credentials',
            '-t',
            '-c', credentials,
            '-r', region,
            '-a', access_key_id,
            '-s', secret_access_key
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Generators::Credentials
      ).to receive(:generate).once.with(
        *expected_params
      )
      Test.new.run
    end
  end

  context 'with all long form options' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'credentials',
            '-t',
            '--credentials', credentials,
            '--region', region,
            '--access-key-id', access_key_id,
            '--secret-access-key', secret_access_key
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Generators::Credentials
      ).to receive(:generate).once.with(
        *expected_params
      )
      Test.new.run
    end
  end

  context 'with global default credentials file' do
    before(:each) do
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'credentials',
            '-t',
            '--region', region,
            '--access-key-id', access_key_id,
            '--secret-access-key', secret_access_key
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new "\n"
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Generators::Credentials
      ).to receive(:generate).once.with(
        File.join(Dir.home, '.formatron/credentials.json'),
        region,
        access_key_id,
        secret_access_key
      )
      Test.new.run
    end
  end

  context 'with local default credentials file' do
    before(:each) do
      File.write 'Formatronfile', ''
      allow(Commander::Runner).to receive(:instance) do
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'credentials',
            '-t',
            '--region', region,
            '--access-key-id', access_key_id,
            '--secret-access-key', secret_access_key
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new "\n"
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(
        Formatron::Generators::Credentials
      ).to receive(:generate).once.with(
        File.join(Dir.pwd, '.formatron/credentials.json'),
        region,
        access_key_id,
        secret_access_key
      )
      Test.new.run
    end
  end
end
