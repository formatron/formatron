require 'spec_helper'
require 'formatron'

xdescribe Formatron do
  before(:each) do
    @directory = 'test/directory'
    @credentials = 'test/credentials'
    @target = 'target'
    @kms_key = 'kms_key'
    @name = 'name'
    @bucket = 'bucket'
    @protected = 'protected'
    @config = 'config'
    @file = File.join @directory, 'Formatronfile'
    @cloud_formation_template = 'cloud_formation_template'
    @hosted_zone_id = 'hosted_zone_id'
    @hosted_zone_name = 'hosted_zone_name'
    @config_key = 'config_key'
    @user_pem_key = 'user_pem_key'
    @organization_pem_key = 'organization_pem_key'
    @ssl_cert_key = 'ssl_cert_key'
    @ssl_key_key = 'ssl_key_key'
    @chef_ssl_cert = 'chef_ssl_cert'
    @chef_ssl_key = 'chef_ssl_key'

    @aws_class = class_double(
      'Formatron::AWS'
    ).as_stubbed_const
    @aws = instance_double('Formatron::AWS')
    allow(@aws_class).to receive(:new) { @aws }
    allow(@aws).to receive(
      :hosted_zone_name
    ).with(@hosted_zone_id) { @hosted_zone_name }

    @config_class = class_double(
      'Formatron::Config'
    ).as_stubbed_const
    allow(@config_class).to receive(:target).with(
      directory: @directory,
      target: @target
    ) { @config }

    @cloud_formation = class_double(
      'Formatron::CloudFormation'
    ).as_stubbed_const

    @bootstrap_template = class_double(
      'Formatron::CloudFormation::BootstrapTemplate'
    ).as_stubbed_const
    allow(@bootstrap_template).to receive(:json) { @cloud_formation_template }

    @s3_configuration = class_double(
      'Formatron::S3::Configuration'
    ).as_stubbed_const
    allow(@s3_configuration).to receive(:key) { @config_key }

    @s3_cloud_formation_template = class_double(
      'Formatron::S3::CloudFormationTemplate'
    ).as_stubbed_const

    @s3_chef_server_cert = class_double(
      'Formatron::S3::ChefServerCert'
    ).as_stubbed_const
    allow(@s3_chef_server_cert).to receive(:cert_key) { @ssl_cert_key }
    allow(@s3_chef_server_cert).to receive(:key_key) { @ssl_key_key }

    @s3_chef_server_keys = class_double(
      'Formatron::S3::ChefServerKeys'
    ).as_stubbed_const
    allow(@s3_chef_server_keys).to receive(:user_pem_key) { @user_pem_key }
    allow(@s3_chef_server_keys).to receive(
      :organization_pem_key
    ) { @organization_pem_key }
    allow(@s3_chef_server_keys).to receive(:destroy)

    @chef_class = class_double(
      'Formatron::Chef'
    ).as_stubbed_const
    @chef = instance_double 'Formatron::Chef'
    allow(@chef_class).to receive(:new) { @chef }
    allow(@chef).to receive(:unlink)
    allow(@chef).to receive(:init)

    @formatron = Formatron.new(
      credentials: @credentials,
      directory: @directory,
      target: @target
    )
  end

  it 'should create an AWS instance' do
    expect(@aws_class).to have_received(:new).once.with(
      credentials: @credentials
    )
  end

  it 'should create a Chef instance' do
    expect(@chef_class).to have_received(:new).once.with(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target,
      username: @username,
      organization: @organization_short_name,
      ssl_verify: @ssl_verify,
      chef_sub_domain: @chef_sub_domain,
      private_key: @private_key,
      bastion_sub_domain: @bastion_sub_domain,
      hosted_zone_name: @hosted_zone_name,
      server_stack: @name
    )
  end

  it 'should create a Formatronfile instance' do
    expect(@formatronfile_class).to have_received(:new).once.with(
      aws: @aws,
      config: @config,
      target: @target,
      file: @file
    )
  end

  it 'should generate the bootstrap CloudFormation template' do
    expect(@bootstrap_template).to have_received(:json).once.with(
      hosted_zone_id: @hosted_zone_id,
      hosted_zone_name: @hosted_zone_name,
      bootstrap: @bootstrap,
      bucket: @bucket,
      config_key: @config_key,
      user_pem_key: @user_pem_key,
      organization_pem_key: @organization_pem_key,
      ssl_cert_key: @ssl_cert_key,
      ssl_key_key: @ssl_key_key
    )
  end

  describe '#instance' do
    skip 'should return the formatronfile instance matching the name' do
    end
  end

  describe '#hosted_zone_name' do
    skip 'should return the hosted zone name for the configuration' do
    end
  end

  describe '#kms_key' do
    skip 'should return the KMS key ID for the configuration' do
    end
  end

  describe '#protected?' do
    it 'should return whether the target should be protected from changes' do
      expect(@formatron.protected?).to eql @protected
    end
  end

  describe '#deploy' do
    before(:each) do
      allow(@s3_configuration).to receive(:deploy)
      allow(@s3_cloud_formation_template).to receive(:deploy)
      allow(@s3_chef_server_cert).to receive(:deploy)
      allow(@cloud_formation).to receive(:deploy)
      @formatron.deploy
    end

    it 'should upload the configuration to S3' do
      expect(@s3_configuration).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: @target,
        config: @config
      )
    end

    it 'should upload the CloudFormation template to S3' do
      expect(@s3_cloud_formation_template).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: @target,
        cloud_formation_template: @cloud_formation_template
      )
    end

    it 'should deploy the CloudFormation stack' do
      expect(@cloud_formation).to have_received(:deploy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target
      )
    end

    it 'should upload the Chef Server SSL certificate and key to S3' do
      expect(@s3_chef_server_cert).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: @target,
        cert: @chef_ssl_cert,
        key: @chef_ssl_key
      )
    end
  end

  describe '#provision' do
    before :each do
      allow(@chef).to receive :provision
      @formatron.provision
    end

    it 'should create the chef client config' do
      expect(@chef).to have_received :init
    end

    it 'should provision the instances with Chef' do
      expect(@chef).to have_received(:provision).once.with(
        sub_domain: @bastion_sub_domain,
        cookbook: @bastion_cookbook
      )
      expect(@chef).to have_received(:provision).once.with(
        sub_domain: @nat_sub_domain,
        cookbook: @nat_cookbook
      )
      expect(@chef).to have_received(:provision).once.with(
        sub_domain: @chef_sub_domain,
        cookbook: @chef_cookbook
      )
    end
  end

  describe '#destroy' do
    before(:each) do
      allow(@s3_configuration).to receive(:destroy)
      allow(@s3_cloud_formation_template).to receive(:destroy)
      allow(@s3_chef_server_cert).to receive(:destroy)
      allow(@cloud_formation).to receive(:destroy)
      allow(@chef).to receive(:destroy)
      @formatron.destroy
    end

    it 'should create the chef client config' do
      expect(@chef).to have_received :init
    end

    it 'should delete the configuration from S3' do
      expect(@s3_configuration).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target
      )
    end

    context 'when an error occurs deleting the configuration from S3' do
      it 'should continue' do
        allow(@s3_configuration).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should delete the CloudFormation template from S3' do
      expect(@s3_cloud_formation_template).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target
      )
    end

    context 'when an error occurs deleting the ' \
            'CloudFormation template from S3' do
      it 'should continue' do
        allow(@s3_cloud_formation_template).to receive(
          :destroy
        ) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should destroy the CloudFormation stack' do
      expect(@cloud_formation).to have_received(:destroy).once.with(
        aws: @aws,
        name: @name,
        target: @target
      )
    end

    context 'when an error occurs deleting the CloudFormation stack' do
      it 'should continue' do
        allow(@cloud_formation).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should delete the Chef Server SSL certificate and key from S3' do
      expect(@s3_chef_server_cert).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target
      )
    end

    context 'when an error occurs deleting the Chef Server ' \
            'certificate and key from S3' do
      it 'should continue' do
        allow(@s3_chef_server_cert).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should delete the Chef Server user and organization keys from S3' do
      expect(@s3_chef_server_keys).to have_received(:destroy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target
      )
    end

    context 'when an error occurs deleting the Chef Server ' \
            'user and organization keys from S3' do
      it 'should continue' do
        allow(@s3_chef_server_keys).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should cleanup the Chef Server configuration for the instances' do
      expect(@chef).to have_received(:destroy).once.with(
        sub_domain: @bastion_sub_domain
      )
      expect(@chef).to have_received(:destroy).once.with(
        sub_domain: @nat_sub_domain
      )
      expect(@chef).to have_received(:destroy).once.with(
        sub_domain: @chef_sub_domain
      )
    end

    context 'when an error occurs cleaning up the Chef Server ' \
            'configuration for the instances' do
      it 'should continue' do
        allow(@chef).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end
  end
end
