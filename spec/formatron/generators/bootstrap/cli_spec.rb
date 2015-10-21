require 'spec_helper'

require 'formatron/cli'
require 'formatron/generators/bootstrap/cli'

describe Formatron::Generators::Bootstrap::CLI do
  include FakeFS::SpecHelpers

  # Test harness
  class Test < Formatron::CLI
    include Formatron::Generators::Bootstrap::CLI
  end

  directory = 'directory'
  name = 'test'
  s3_bucket = 's3-bucket'
  kms_key = 'kms-key'
  ec2_key = 'ec2-key'
  hosted_zone_id = 'ABCDEF'
  organization = 'organization'
  username = 'username'
  email = 'email'
  first_name = 'first-name'
  last_name = 'last-name'
  targets = %w(target1 target2)
  target_params = {}
  targets.each do |target|
    target_sym = target.to_sym
    target_params[target_sym] = {}
    target_params[target_sym][:protect] = true
    target_params[target_sym][:sub_domain] = "#{target}-sub-domain"
    target_params[target_sym][:password] = "#{target}-password"
  end

  expected_params = {
    name: name,
    s3_bucket: s3_bucket,
    kms_key: kms_key,
    ec2_key: ec2_key,
    hosted_zone_id: hosted_zone_id,
    organization: organization,
    username: username,
    email: email,
    first_name: first_name,
    last_name: last_name,
    targets: target_params
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
        @singleton ||= Commander::Runner.new ['bootstrap', '-t']
      end
    end

    it 'should prompt for parameters' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{directory}
        #{name}
        #{s3_bucket}
        #{kms_key}
        #{ec2_key}
        #{hosted_zone_id}
        #{organization}
        #{username}
        #{email}
        #{first_name}
        #{last_name}
        #{targets.join(' ')}
      EOH
      targets.each do |target|
        target_sym = target.to_sym
        responses << <<-EOH.gsub(/^ {10}/, '')
          #{target_params[target_sym][:protect] ? 'yes' : 'no'}
          #{target_params[target_sym][:sub_domain]}
          #{target_params[target_sym][:password]}
        EOH
      end
      @input = StringIO.new responses
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Bootstrap).to receive(:generate).once.with(
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
            'bootstrap',
            '-t',
            '-d', directory,
            '-n', name,
            '-s', s3_bucket,
            '-k', kms_key,
            '-e', ec2_key,
            '-z', hosted_zone_id,
            '-o', organization,
            '-u', username,
            '-m', email,
            '-f', first_name,
            '-l', last_name,
            '-j', "'#{target_params.to_json space: ' '}'"
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Bootstrap).to receive(:generate).once.with(
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
            'bootstrap',
            '-t',
            '--directory', directory,
            '--name', name,
            '--s3-bucket', s3_bucket,
            '--kms-key', kms_key,
            '--ec2-key', ec2_key,
            '--hosted-zone-id', hosted_zone_id,
            '--organization', organization,
            '--username', username,
            '--email', email,
            '--first-name', first_name,
            '--last-name', last_name,
            '--targets-json', "'#{target_params.to_json space: ' '}'"
          ]
      end
    end

    it 'should call generate' do
      @input = StringIO.new
      @output = StringIO.new
      # rubocop:disable Style/GlobalVars
      $terminal = HighLine.new @input, @output
      # rubocop:enable Style/GlobalVars
      expect(Formatron::Generators::Bootstrap).to receive(:generate).once.with(
        directory,
        expected_params
      )
      Test.new.run
    end
  end
end
