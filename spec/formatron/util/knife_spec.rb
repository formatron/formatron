require 'spec_helper'

ENVIRONMENT = 'env'
ENVIRONMENT_CHECK_COMMAND = "knife environment show #{ENVIRONMENT} " \
                            '-c knife_file'
ENVIRONMENT_CREATE_COMMAND = "knife environment create #{ENVIRONMENT} -c " \
                             "knife_file -d '#{ENVIRONMENT} environment " \
                             "created by formatron'"

describe Formatron::Util::Knife do
  before(:each) do
    @key_tempfile = instance_double('Tempfile')
    allow(@key_tempfile).to receive(:write)
    allow(@key_tempfile).to receive(:close)
    allow(@key_tempfile).to receive(:unlink)
    allow(@key_tempfile).to receive(:path) do
      'key_file'
    end
    @knife_tempfile = instance_double('Tempfile')
    allow(@knife_tempfile).to receive(:write)
    allow(@knife_tempfile).to receive(:close)
    allow(@knife_tempfile).to receive(:unlink)
    allow(@knife_tempfile).to receive(:path) do
      'knife_file'
    end
    @tempfile_class = class_double('Tempfile').as_stubbed_const
    allow(@tempfile_class).to receive(:new) do |name|
      case name
      when 'knife_key'
        @key_tempfile
      when 'knife'
        @knife_tempfile
      end
    end
  end

  context 'when verifying SSL certs' do
    before(:each) do
      @knife = Formatron::Util::Knife.new(
        'http://server',
        'user',
        'key',
        'organization',
        true
      )
    end

    it 'should create a temporary file for the knife
    config setting the verify more to :verify_peer' do
      expect(@tempfile_class).to have_received(:new).with('knife').once
      expect(@knife_tempfile).to have_received(:write).with(
        <<-EOH.gsub(/^\s{8}/, '')
          chef_server_url 'http://server/organizations/organization'
          node_name 'user'
          client_key 'key_file'
          ssl_verify_mode :verify_peer
        EOH
      ).once
      expect(@knife_tempfile).to have_received(:close).with(no_args).once
    end
  end

  context 'when not verifying SSL certs' do
    before(:each) do
      @knife = Formatron::Util::Knife.new(
        'http://server',
        'user',
        'key',
        'organization',
        false
      )
    end

    it 'should create a temporary file for the knife
    config setting the verify more to :verify_none' do
      expect(@tempfile_class).to have_received(:new).with('knife').once
      expect(@knife_tempfile).to have_received(:write).with(
        <<-EOH.gsub(/^\s{8}/, '')
          chef_server_url 'http://server/organizations/organization'
          node_name 'user'
          client_key 'key_file'
          ssl_verify_mode :verify_none
        EOH
      ).once
      expect(@knife_tempfile).to have_received(:close).with(no_args).once
    end
  end

  it 'should create a temporary file for the chef key' do
    @knife = Formatron::Util::Knife.new(
      'http://server',
      'user',
      'key',
      'organization',
      true
    )
    expect(@tempfile_class).to have_received(:new).with('knife_key').once
    expect(@key_tempfile).to have_received(:write).with('key').once
    expect(@key_tempfile).to have_received(:close).with(no_args).once
  end

  describe '#unlink' do
    before(:each) do
      @knife = Formatron::Util::Knife.new(
        'http://server',
        'user',
        'key',
        'organization',
        true
      )
      @knife.unlink
    end

    it 'should delete the chef key file' do
      expect(@key_tempfile).to have_received(:unlink).with(no_args).once
    end

    it 'should delete the knife config file' do
      expect(@knife_tempfile).to have_received(:unlink).with(no_args).once
    end
  end

  describe '#createEnvironment' do
    before(:each) do
      @knife = Formatron::Util::Knife.new(
        'http://server',
        'user',
        'key',
        'organization',
        true
      )
    end

    context 'when the environment already exists' do
      before(:each) do
        @kernel_helper_class = class_double(
          'Formatron::Util::KernelHelper'
        ).as_stubbed_const
        allow(@kernel_helper_class).to receive(:shell) do |command|
          case command
          when ENVIRONMENT_CHECK_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { true }
          when ENVIRONMENT_CREATE_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { true }
          else
            allow(@kernel_helper_class).to receive(:success?) { false }
          end
        end
      end

      it 'should do nothing' do
        @knife.create_environment(ENVIRONMENT)
        expect(@kernel_helper_class).to have_received(:shell).once
        expect(@kernel_helper_class).to have_received(:shell).with(
          ENVIRONMENT_CHECK_COMMAND
        )
      end
    end

    context 'when the environment does not exist' do
      before(:each) do
        @kernel_helper_class = class_double(
          'Formatron::Util::KernelHelper'
        ).as_stubbed_const
        allow(@kernel_helper_class).to receive(:shell) do |command|
          case command
          when ENVIRONMENT_CHECK_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { false }
          when ENVIRONMENT_CREATE_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { true }
          else
            allow(@kernel_helper_class).to receive(:success?) { false }
          end
        end
      end

      it 'should create the environment' do
        @knife.create_environment(ENVIRONMENT)
        expect(@kernel_helper_class).to have_received(:shell).twice
        expect(@kernel_helper_class).to have_received(:shell).with(
          ENVIRONMENT_CHECK_COMMAND
        )
        expect(@kernel_helper_class).to have_received(:shell).with(
          ENVIRONMENT_CREATE_COMMAND
        )
      end
    end

    context 'when the environment fails to create' do
      before(:each) do
        @kernel_helper_class = class_double(
          'Formatron::Util::KernelHelper'
        ).as_stubbed_const
        allow(@kernel_helper_class).to receive(:shell) do |command|
          case command
          when ENVIRONMENT_CHECK_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { false }
          when ENVIRONMENT_CREATE_COMMAND
            allow(@kernel_helper_class).to receive(:success?) { false }
          else
            allow(@kernel_helper_class).to receive(:success?) { false }
          end
        end
      end

      it 'should fail' do
        expect { @knife.create_environment(ENVIRONMENT) }.to raise_error(
          Formatron::Util::Knife::CreateEnvironmentError
        )
      end
    end
  end
end
