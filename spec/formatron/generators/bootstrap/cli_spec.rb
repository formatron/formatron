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
  ec2_key_pair = 'ec2-key-_pair'
  hosted_zone_id = 'ABCDEF'
  availability_zone = 'b'
  organization = 'organization'
  username = 'username'
  email = 'email'
  first_name = 'first-name'
  last_name = 'last-name'
  password = 'password'
  protected_targets = %w(target1)
  unprotected_targets = %w(target2)
  target_params = {}
  protected_targets.each do |target|
    target_sym = target.to_sym
    target_params[target_sym] = {}
    target_params[target_sym][:protect] = true
  end
  unprotected_targets.each do |target|
    target_sym = target.to_sym
    target_params[target_sym] = {}
    target_params[target_sym][:protect] = false
  end

  expected_params = {
    name: name,
    s3_bucket: s3_bucket,
    kms_key: kms_key,
    ec2_key_pair: ec2_key_pair,
    hosted_zone_id: hosted_zone_id,
    availability_zone: availability_zone,
    chef_server: {
      organization: organization,
      username: username,
      password: password,
      email: email,
      first_name: first_name,
      last_name: last_name
    },
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
        @singleton ||=
          Commander::Runner.new [
            'generate',
            'bootstrap',
            '-t'
          ]
      end
    end

    it 'should prompt for parameters' do
      responses = <<-EOH.gsub(/^ {8}/, '')
        #{directory}
        #{name}
        #{s3_bucket}
        #{kms_key}
        #{ec2_key_pair}
        #{hosted_zone_id}
        #{availability_zone}
        #{organization}
        #{username}
        #{password}
        #{email}
        #{first_name}
        #{last_name}
        #{protected_targets.join ' '}
        #{unprotected_targets.join ' '}
      EOH
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
            'generate',
            'bootstrap',
            '-t',
            '-d', directory,
            '-n', name,
            '-s', s3_bucket,
            '-k', kms_key,
            '-e', ec2_key_pair,
            '-z', hosted_zone_id,
            '-a', availability_zone,
            '-o', organization,
            '-u', username,
            '-p', password,
            '-m', email,
            '-f', first_name,
            '-l', last_name,
            '-x', protected_targets.join(','),
            '-y', unprotected_targets.join(',')
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
            'generate',
            'bootstrap',
            '-t',
            '--directory', directory,
            '--name', name,
            '--s3-bucket', s3_bucket,
            '--kms-key', kms_key,
            '--ec2-key-pair', ec2_key_pair,
            '--hosted-zone-id', hosted_zone_id,
            '--availability-zone', availability_zone,
            '--organization', organization,
            '--username', username,
            '--password', password,
            '--email', email,
            '--first-name', first_name,
            '--last-name', last_name,
            '--protected-targets', protected_targets.join(','),
            '--unprotected-targets', unprotected_targets.join(',')
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
