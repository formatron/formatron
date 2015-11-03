require 'spec_helper'

require 'formatron'

describe Formatron do
  directory = 'test/directory'
  credentials = 'test/credentials'

  before(:each) do
    @kms_key = 'kms_key'
    @name = 'name'
    @bucket = 'bucket'
    @config = 'config'
    @cloud_formation_template = 'cloud_formation_template'
    @aws_class = class_double(
      'Formatron::AWS'
    ).as_stubbed_const
    @aws = instance_double('Formatron::AWS')
    allow(@aws_class).to receive(:new) { @aws }

    @configuration_class = class_double(
      'Formatron::Configuration'
    ).as_stubbed_const
    @configuration = instance_double('Formatron::Configuration')
    allow(@configuration_class).to receive(:new) { @configuration }
    allow(@configuration).to receive(:kms_key) { @kms_key }
    allow(@configuration).to receive(:name) { @name }
    allow(@configuration).to receive(:bucket) { @bucket }
    allow(@configuration).to receive(:config) { @config }
    allow(@configuration).to receive(
      :cloud_formation_template
    ) { @cloud_formation_template }
    allow(@configuration).to receive(
      :chef_server_ssl_cert
    ) { nil }
    allow(@configuration).to receive(
      :chef_server_ssl_key
    ) { nil }

    @formatron = Formatron.new(
      credentials,
      directory
    )
  end

  describe('::new') do
    it 'should create an AWS instance' do
      expect(@aws_class).to have_received(:new).once.with(credentials)
    end

    it 'should create a Configuration instance' do
      expect(@configuration_class).to have_received(:new).once.with(
        @aws,
        directory
      )
    end
  end

  describe '#targets' do
    it 'should get the list of targets from the formatronfile' do
      targets = %w(target1 target2 target3)
      expect(@configuration).to receive(:targets).once.with(no_args) { targets }
      expect(@formatron.targets).to eql targets
    end
  end

  describe '#protected?' do
    it 'should return whether the target should be protected from changes' do
      expect(@configuration).to receive(:protected?)
        .once.with('target1') { true }
      expect(@formatron.protected?('target1')).to eql true
    end
  end

  describe '#deploy' do
    before(:each) do
      @s3_configuration = class_double(
        'Formatron::S3Configuration'
      ).as_stubbed_const
      allow(@s3_configuration).to receive(:deploy)

      @s3_cloud_formation_template = class_double(
        'Formatron::S3CloudFormationTemplate'
      ).as_stubbed_const
      allow(@s3_cloud_formation_template).to receive(:deploy)

      @cloud_formation_stack = class_double(
        'Formatron::CloudFormationStack'
      ).as_stubbed_const
      allow(@cloud_formation_stack).to receive(:deploy)
    end

    it 'should upload the configuration to S3' do
      @formatron.deploy 'target1'
      expect(@configuration).to have_received(:kms_key).once.with('target1')
      expect(@configuration).to have_received(:bucket).once.with('target1')
      expect(@configuration).to have_received(:name).once.with('target1')
      expect(@configuration).to have_received(:config).once.with('target1')
      expect(@s3_configuration).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: 'target1',
        config: @config
      )
    end

    it 'should upload the CloudFormation template to S3' do
      @formatron.deploy 'target1'
      expect(@configuration).to have_received(:kms_key).once.with('target1')
      expect(@configuration).to have_received(:bucket).once.with('target1')
      expect(@configuration).to have_received(:name).once.with('target1')
      expect(@configuration).to have_received(
        :cloud_formation_template
      ).once.with('target1')
      expect(@s3_cloud_formation_template).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: 'target1',
        cloud_formation_template: @cloud_formation_template
      )
    end

    it 'should deploy the CloudFormation stack' do
      @formatron.deploy 'target1'
      expect(@cloud_formation_stack).to have_received(:deploy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: 'target1'
      )
    end

    context 'when there is a bootstrap configuration' do
      before :each do
        @s3_chef_server_cert = class_double(
          'Formatron::S3ChefServerCert'
        ).as_stubbed_const
        allow(@s3_chef_server_cert).to receive(:deploy)
        @ssl_cert = 'ssl_cert'
        @ssl_key = 'ssl_key'
        allow(@configuration).to receive(
          :chef_server_ssl_cert
        ) { @ssl_cert }
        allow(@configuration).to receive(
          :chef_server_ssl_key
        ) { @ssl_key }
      end

      it 'should upload the Chef Server SSL certificate and key to S3' do
        @formatron.deploy 'target1'
        expect(@configuration).to have_received(:kms_key).once.with('target1')
        expect(@configuration).to have_received(:bucket).once.with('target1')
        expect(@configuration).to have_received(:name).once.with('target1')
        expect(@configuration).to have_received(
          :chef_server_ssl_cert
        ).once.with('target1')
        expect(@configuration).to have_received(
          :chef_server_ssl_key
        ).once.with('target1')
        expect(@s3_chef_server_cert).to have_received(:deploy).once.with(
          aws: @aws,
          kms_key: @kms_key,
          bucket: @bucket,
          name: @name,
          target: 'target1',
          cert: @ssl_cert,
          key: @ssl_key
        )
      end
    end
  end

  describe '#provision' do
    before(:each) do
      @chef_instances = class_double(
        'Formatron::ChefInstances'
      ).as_stubbed_const
      allow(@chef_instances).to receive(:provision)
    end

    it 'should provision the instances with Chef' do
      @formatron.provision 'target1'
      expect(@chef_instances).to have_received(:provision).once.with(
        aws: @aws,
        configuration: @configuration,
        target: 'target1'
      )
    end
  end

  describe '#destroy' do
    before(:each) do
      @s3_configuration = class_double(
        'Formatron::S3Configuration'
      ).as_stubbed_const
      allow(@s3_configuration).to receive(:destroy)

      @s3_cloud_formation_template = class_double(
        'Formatron::S3CloudFormationTemplate'
      ).as_stubbed_const
      allow(@s3_cloud_formation_template).to receive(:destroy)

      @cloud_formation_stack = class_double(
        'Formatron::CloudFormationStack'
      ).as_stubbed_const
      allow(@cloud_formation_stack).to receive(:destroy)

      @chef_instances = class_double(
        'Formatron::ChefInstances'
      ).as_stubbed_const
      allow(@chef_instances).to receive(:destroy)
    end

    it 'should delete the configuration from S3' do
      @formatron.destroy 'target1'
      expect(@configuration).to have_received(:bucket).once.with('target1')
      expect(@configuration).to have_received(:name).once.with('target1')
      expect(@s3_configuration).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: 'target1'
      )
    end

    it 'should delete the CloudFormation template from S3' do
      @formatron.destroy 'target1'
      expect(@configuration).to have_received(:bucket).once.with('target1')
      expect(@configuration).to have_received(:name).once.with('target1')
      expect(@s3_cloud_formation_template).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: 'target1'
      )
    end

    it 'should destroy the CloudFormation stack' do
      @formatron.destroy 'target1'
      expect(@cloud_formation_stack).to have_received(:destroy).once.with(
        aws: @aws,
        name: @name,
        target: 'target1'
      )
    end

    it 'should cleanup the Chef Server configuration for the instances' do
      @formatron.destroy 'target1'
      expect(@chef_instances).to have_received(:destroy).once.with(
        aws: @aws,
        configuration: @configuration,
        target: 'target1'
      )
    end

    context 'when there is a bootstrap configuration' do
      before :each do
        @s3_chef_server_cert = class_double(
          'Formatron::S3ChefServerCert'
        ).as_stubbed_const
        allow(@s3_chef_server_cert).to receive(:destroy)
        @ssl_cert = 'ssl_cert'
        @ssl_key = 'ssl_key'
        allow(@configuration).to receive(
          :chef_server_ssl_cert
        ) { @ssl_cert }
      end

      it 'should delete the Chef Server SSL certificate and key from S3' do
        @formatron.destroy 'target1'
        expect(@configuration).to have_received(:bucket).once.with('target1')
        expect(@configuration).to have_received(:name).once.with('target1')
        expect(@configuration).to have_received(
          :chef_server_ssl_cert
        ).once.with('target1')
        expect(@s3_chef_server_cert).to have_received(:destroy).once.with(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: 'target1'
        )
      end
    end
  end
end
