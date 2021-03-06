require 'spec_helper'

require 'formatron/cli'
require 'formatron/cli/generators/instance'

describe Formatron::CLI::Generators::Instance do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::CLI::Generators::Instance
  end

  directory = 'directory'
  name = 'test'
  s3_bucket = 's3_bucket'
  bootstrap_configuration = 'bootstrap_configuration'
  vpc = 'vpc'
  subnet = 'subnet'
  instance_name = 'instance'
  targets = %w(target1 target2)

  expected_params = {
    name: name,
    s3_bucket: s3_bucket,
    bootstrap_configuration: bootstrap_configuration,
    vpc: vpc,
    subnet: subnet,
    instance_name: instance_name,
    targets: targets
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
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'instance',
            '-t'
          ]
      end
    end

    it 'should prompt for parameters' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{directory}
        #{name}
        #{instance_name}
        #{s3_bucket}
        #{bootstrap_configuration}
        #{vpc}
        #{subnet}
        #{targets.join(' ')}
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
            'generate',
            'instance',
            '-t',
            '-d', directory,
            '-n', name,
            '-i', instance_name,
            '-s', s3_bucket,
            '-b', bootstrap_configuration,
            '-p', vpc,
            '-u', subnet,
            '-x', targets.join(',')
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
            'generate',
            'instance',
            '-t',
            '--directory', directory,
            '--name', name,
            '--instance-name', instance_name,
            '--s3-bucket', s3_bucket,
            '--bootstrap-configuration', bootstrap_configuration,
            '--vpc', vpc,
            '--subnet', subnet,
            '--targets', targets.join(',')
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
