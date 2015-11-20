require 'spec_helper'
require 'formatron'

describe Formatron do
  before(:each) do
    stub_const 'Formatron::LOG', Logger.new('/dev/null')
    @directory = 'test/directory'
    @credentials = 'test/credentials'
    @target = 'target'
    @config = 'config'
    @file = File.join @directory, 'Formatronfile'
    @cloud_formation_template = 'cloud_formation_template'
    @hosted_zone_name = 'hosted_zone_name'
    @config_key = 'config_key'
    @user_pem_key = 'user_pem_key'
    @organization_pem_key = 'organization_pem_key'
    @hosted_zone_id = 'hosted_zone_id'

    @aws_class = class_double(
      'Formatron::AWS'
    ).as_stubbed_const
    @aws = instance_double('Formatron::AWS')
    allow(@aws_class).to receive(:new) { @aws }
    allow(@aws).to receive(
      :hosted_zone_name
    ).with(@hosted_zone_id) { @hosted_zone_name }

    @external_class = class_double(
      'Formatron::External'
    ).as_stubbed_const
    @external = instance_double('Formatron::External')
    allow(@external_class).to receive(:new).with(
      target: @target,
      aws: @aws,
      config: @config
    ) { @external }
    @external_formatron = instance_double 'Formatron::DSL::Formatron'
    allow(@external).to receive(:formatron) { @external_formatron }
    @external_vpcs = 'external_vpcs'
    allow(@external_formatron).to receive(:vpc) { @external_vpcs }
    @external_global = instance_double 'Formatron::DSL::Formatron::Global'
    allow(@external_formatron).to receive(:global) { @external_global }
    @external_ec2 = instance_double(
      'Formatron::DSL::Formatron::Global:EC2'
    )
    allow(@external_global).to receive(:ec2) { @external_ec2 }
    external_outputs = instance_double 'Formatron::External::Outputs'
    allow(@external).to receive(:outputs) { external_outputs }
    @external_outputs_hash = 'external_outputs_hash'
    allow(external_outputs).to receive(:hash) { @external_outputs_hash }

    dsl = instance_double 'Formatron::DSL'
    @dsl_class = class_double(
      'Formatron::DSL'
    ).as_stubbed_const
    allow(@dsl_class).to receive(:new).with(
      file: @file,
      target: @target,
      config: @config,
      external: @external
    ) { dsl }

    @dsl_formatron = instance_double 'Formatron::DSL::Formatron'
    allow(dsl).to receive(:formatron) { @dsl_formatron }
    @name = 'name'
    allow(@dsl_formatron).to receive(:name).with(no_args) { @name }
    @bucket = 'bucket'
    allow(@dsl_formatron).to receive(:bucket).with(no_args) { @bucket }

    @configuration = 'configuration'
    allow(@external).to receive(:export).with(
      formatron: @dsl_formatron
    ) { @configuration }

    global = instance_double 'Formatron::DSL::Formatron::Global'
    allow(@dsl_formatron).to receive(:global).with(no_args) { global }
    @protect = 'protect'
    allow(global).to receive(:protect).with(no_args) { @protect }
    @kms_key = 'kms_key'
    allow(global).to receive(:kms_key).with(no_args) { @kms_key }
    @databag_secret = 'databag_secret'
    allow(global).to receive(:databag_secret).with(no_args) { @databag_secret }
    allow(global).to receive(:hosted_zone_id).with(no_args) { @hosted_zone_id }

    ec2 = instance_double 'Formatron::DSL::Formatron::Global::EC2'
    allow(global).to receive(:ec2).with(no_args) { ec2 }
    @key_pair = 'key_pair'
    allow(ec2).to receive(:key_pair).with(no_args) { @key_pair }
    @ec2_key = 'ec2_key'
    allow(ec2).to receive(:private_key).with(no_args) { @ec2_key }

    vpcs = {}
    @chef_class = class_double(
      'Formatron::Chef'
    ).as_stubbed_const
    @chef_clients = []
    @bastion_sub_domains = {}
    (0..2).each do |vpc_index|
      vpc_chef_clients = @chef_clients[vpc_index] = []
      vpc_key = "vpc#{vpc_index}"
      vpc = instance_double 'Formatron::DSL::Formatron::VPC'
      vpcs[vpc_key] = vpc
      subnets = {}
      bastion_sub_domains = @bastion_sub_domains[vpc_key] = {}
      (0..2).each do |subnet_index|
        subnet_chef_clients = vpc_chef_clients[subnet_index] = []
        subnet_index = "#{vpc_index}_#{subnet_index}"
        subnet_key = "subnet#{subnet_index}"
        subnet = instance_double 'Formatron::DSL::Formatron::VPC::Subnet'
        subnets[subnet_key] = subnet
        chef_servers = {}
        (0..2).each do |chef_server_index|
          chef = subnet_chef_clients[chef_server_index] = instance_double(
            'Formatron::Chef'
          )
          chef_server_index = "#{subnet_index}_#{chef_server_index}"
          username = "chef_server_username#{chef_server_index}"
          organization_name = "organization#{chef_server_index}"
          ssl_verify = "chef_server_ssl_verify#{chef_server_index}"
          sub_domain = "chef_server_sub_domain#{chef_server_index}"
          guid = "chef_server_guid#{chef_server_index}"
          allow(@chef_class).to receive(:new).with(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target,
            username: username,
            organization: organization_name,
            ssl_verify: ssl_verify,
            chef_sub_domain: sub_domain,
            ec2_key: @ec2_key,
            bastions: bastion_sub_domains,
            hosted_zone_name: @hosted_zone_name,
            server_stack: @name,
            guid: guid,
            configuration: @configuration,
            databag_secret: @databag_secret
          ) { chef }
          allow(chef).to receive :init
          allow(chef).to receive :unlink
          allow(chef).to receive :provision
          allow(chef).to receive :destroy
          allow(chef).to receive :deploy_databag
          allow(chef).to receive :delete_databag
          chef_server_key = "chef_server#{chef_server_index}"
          chef_server = instance_double 'Formatron::DSL::Formatron::VPC' \
                                        '::Subnet::ChefServer'
          chef_servers[chef_server_key] = chef_server
          dsl_chef = instance_double(
            'Formatron::DSL::VPC::Subnet::Instance::Chef'
          )
          allow(dsl_chef).to receive(:server).with(
            no_args
          ) { chef_server_key }
          allow(dsl_chef).to receive(:cookbook).with(
            no_args
          ) { "chef_server_cookbook#{chef_server_index}" }
          allow(dsl_chef).to receive(:bastion).with(
            no_args
          ) { "bastion#{chef_server_index}" }
          allow(chef_server).to receive(:chef).with(
            no_args
          ) { dsl_chef }
          allow(chef_server).to receive(:username).with(
            no_args
          ) { username }
          allow(chef_server).to receive(:ssl_verify).with(
            no_args
          ) { ssl_verify }
          allow(chef_server).to receive(:sub_domain).with(
            no_args
          ) { sub_domain }
          allow(chef_server).to receive(:guid).with(
            no_args
          ) { guid }
          allow(chef_server).to receive(:ssl_cert).with(
            no_args
          ) { "chef_server_ssl_cert#{chef_server_index}" }
          allow(chef_server).to receive(:ssl_key).with(
            no_args
          ) { "chef_server_ssl_key#{chef_server_index}" }
          allow(chef_server).to receive(:stack).with(
            no_args
          ) { nil }

          organization = instance_double 'Formatron::DSL::Formatron::VPC' \
                                         '::Subnet::ChefServer::Organization'
          allow(chef_server).to receive(:organization).with(
            no_args
          ) { organization }
          allow(organization).to receive(:short_name).with(
            no_args
          ) { organization_name }
        end
        allow(subnet).to receive(:chef_server).with(no_args) { chef_servers }
        bastions = {}
        (0..2).each do |bastion_index|
          bastion_index = "#{subnet_index}_#{bastion_index}"
          bastion_key = "bastion#{bastion_index}"
          bastion = instance_double 'Formatron::DSL::Formatron::VPC' \
                                    '::Subnet::Bastion'
          bastions[bastion_key] = bastion
          bastion_sub_domain = "bastion_sub_domain#{bastion_index}"
          dsl_chef = instance_double(
            'Formatron::DSL::VPC::Subnet::Instance::Chef'
          )
          allow(dsl_chef).to receive(:server).with(
            no_args
          ) { "chef_server#{bastion_index}" }
          allow(dsl_chef).to receive(:cookbook).with(
            no_args
          ) { "bastion_cookbook#{bastion_index}" }
          allow(dsl_chef).to receive(:bastion).with(
            no_args
          ) { "bastion#{bastion_index}" }
          allow(bastion).to receive(:chef).with(
            no_args
          ) { dsl_chef }
          allow(bastion).to receive(:sub_domain).with(
            no_args
          ) { bastion_sub_domain }
          allow(bastion).to receive(:guid).with(
            no_args
          ) { "bastion_guid#{bastion_index}" }
          bastion_sub_domains[bastion_key] = bastion_sub_domain
        end
        allow(subnet).to receive(:bastion).with(no_args) { bastions }
        nats = {}
        (0..2).each do |nat_index|
          nat_index = "#{subnet_index}_#{nat_index}"
          nat_key = "nat#{nat_index}"
          nat = instance_double 'Formatron::DSL::Formatron::VPC' \
                                '::Subnet::NAT'
          nats[nat_key] = nat
          dsl_chef = instance_double(
            'Formatron::DSL::VPC::Subnet::Instance::Chef'
          )
          allow(dsl_chef).to receive(:server).with(
            no_args
          ) { "chef_server#{nat_index}" }
          allow(dsl_chef).to receive(:cookbook).with(
            no_args
          ) { "nat_cookbook#{nat_index}" }
          allow(dsl_chef).to receive(:bastion).with(
            no_args
          ) { "bastion#{nat_index}" }
          allow(nat).to receive(:chef).with(
            no_args
          ) { dsl_chef }
          allow(nat).to receive(:sub_domain).with(
            no_args
          ) { "nat_sub_domain#{nat_index}" }
          allow(nat).to receive(:guid).with(
            no_args
          ) { "nat_guid#{nat_index}" }
        end
        allow(subnet).to receive(:nat).with(no_args) { nats }
        instances = {}
        (0..2).each do |instance_index|
          instance_index = "#{subnet_index}_#{instance_index}"
          instance_key = "instance#{instance_index}"
          instance = instance_double 'Formatron::DSL::Formatron::VPC' \
                                     '::Subnet::Instance'
          instances[instance_key] = instance
          dsl_chef = instance_double(
            'Formatron::DSL::VPC::Subnet::Instance::Chef'
          )
          allow(dsl_chef).to receive(:server).with(
            no_args
          ) { "chef_server#{instance_index}" }
          allow(dsl_chef).to receive(:cookbook).with(
            no_args
          ) { "instance_cookbook#{instance_index}" }
          allow(dsl_chef).to receive(:bastion).with(
            no_args
          ) { "bastion#{instance_index}" }
          allow(instance).to receive(:chef).with(
            no_args
          ) { dsl_chef }
          allow(instance).to receive(:sub_domain).with(
            no_args
          ) { "instance_sub_domain#{instance_index}" }
          allow(instance).to receive(:guid).with(
            no_args
          ) { "instance_guid#{instance_index}" }
        end
        allow(subnet).to receive(:instance).with(no_args) { instances }
      end
      allow(vpc).to receive(:subnet).with(no_args) { subnets }
    end
    allow(@dsl_formatron).to receive(:vpc).with(no_args) { vpcs }

    @cloud_formation = class_double(
      'Formatron::CloudFormation'
    ).as_stubbed_const transfer_nested_constants: true

    @template_class = class_double(
      'Formatron::CloudFormation::Template'
    ).as_stubbed_const
    @template = instance_double 'Formatron::CloudFormation::Template'
    allow(@template_class).to receive(:new).with(
      formatron: @dsl_formatron,
      hosted_zone_name: @hosted_zone_name,
      key_pair: @key_pair,
      kms_key: @kms_key,
      hosted_zone_id: @hosted_zone_id,
      target: @target,
      external: @external
    ) { @template }
    @template_hash = {
      Resources: {
        resource: 'resource'
      }
    }
    allow(@template).to receive(:hash) { @template_hash }
    @template_json = JSON.pretty_generate @template_hash

    @config_class = class_double(
      'Formatron::Config'
    ).as_stubbed_const
    allow(@config_class).to receive(:target).with(
      directory: @directory,
      target: @target
    ) { @config }

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

  it 'should create Chef instances' do
    (0..2).each do |vpc_index|
      vpc_key = "vpc#{vpc_index}"
      (0..2).each do |subnet_index|
        subnet_index = "#{vpc_index}_#{subnet_index}"
        (0..2).each do |chef_server_index|
          chef_server_index = "#{subnet_index}_#{chef_server_index}"
          expect(@chef_class).to have_received(:new).once.with(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target,
            username: "chef_server_username#{chef_server_index}",
            organization: "organization#{chef_server_index}",
            ssl_verify: "chef_server_ssl_verify#{chef_server_index}",
            chef_sub_domain: "chef_server_sub_domain#{chef_server_index}",
            ec2_key: @ec2_key,
            bastions: @bastion_sub_domains[vpc_key],
            hosted_zone_name: @hosted_zone_name,
            server_stack: @name,
            guid: "chef_server_guid#{chef_server_index}",
            configuration: @configuration,
            databag_secret: @databag_secret
          )
        end
      end
    end
  end

  it 'should create a DSL instance' do
    expect(@dsl_class).to have_received(:new).once.with(
      config: @config,
      target: @target,
      file: @file,
      external: @external
    )
  end

  it 'should generate the CloudFormation template' do
    expect(@template_class).to have_received(:new).once.with(
      formatron: @dsl_formatron,
      hosted_zone_name: @hosted_zone_name,
      key_pair: @key_pair,
      kms_key: @kms_key,
      hosted_zone_id: @hosted_zone_id,
      target: @target,
      external: @external
    )
  end

  describe '#protected?' do
    it 'should return whether the target should be protected from changes' do
      expect(@formatron.protected?).to eql @protect
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
        configuration: @configuration
      )
    end

    it 'should upload the CloudFormation template to S3' do
      expect(@s3_cloud_formation_template).to have_received(:deploy).once.with(
        aws: @aws,
        kms_key: @kms_key,
        bucket: @bucket,
        name: @name,
        target: @target,
        cloud_formation_template: @template_json
      )
    end

    it 'should deploy the CloudFormation stack' do
      expect(@cloud_formation).to have_received(:deploy).once.with(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target,
        parameters: @external_outputs_hash
      )
    end

    it 'should upload the Chef Server SSL certificate and key to S3' do
      (0..2).each do |vpc_index|
        (0..2).each do |subnet_index|
          subnet_index = "#{vpc_index}_#{subnet_index}"
          (0..2).each do |chef_server_index|
            chef_server_index = "#{subnet_index}_#{chef_server_index}"
            expect(@s3_chef_server_cert).to have_received(:deploy).once.with(
              aws: @aws,
              kms_key: @kms_key,
              bucket: @bucket,
              name: @name,
              target: @target,
              guid: "chef_server_guid#{chef_server_index}",
              cert: "chef_server_ssl_cert#{chef_server_index}",
              key: "chef_server_ssl_key#{chef_server_index}"
            )
          end
        end
      end
    end

    context 'when there are no resources in the template' do
      before :each do
        @template_hash = {
          Resources: {}
        }
        allow(@template).to receive(:hash) { @template_hash }
        allow(@s3_cloud_formation_template).to receive(:destroy)
        allow(@cloud_formation).to receive(:destroy)
        @formatron = Formatron.new(
          credentials: @credentials,
          directory: @directory,
          target: @target
        )
        @formatron.deploy
      end

      it 'should delete the CloudFormation template from S3' do
        expect(@s3_cloud_formation_template).to have_received(
          :destroy
        ).once.with(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target
        )
      end

      it 'should delete the CloudFormation stack' do
        expect(@cloud_formation).to have_received(:destroy).once.with(
          aws: @aws,
          name: @name,
          target: @target
        )
      end
    end
  end

  describe '#provision' do
    before :each do
      @formatron.provision
    end

    it 'should provision the instances with Chef' do
      (0..2).each do |vpc_index|
        vpc_chef_clients = @chef_clients[vpc_index]
        (0..2).each do |subnet_index|
          subnet_chef_clients = vpc_chef_clients[subnet_index]
          subnet_index = "#{vpc_index}_#{subnet_index}"
          (0..2).each do |chef_server_index|
            chef = subnet_chef_clients[chef_server_index]
            chef_server_index = "#{subnet_index}_#{chef_server_index}"
            expect(chef).to have_received :deploy_databag
            expect(chef).to have_received(:provision).once.with(
              sub_domain: "chef_server_sub_domain#{chef_server_index}",
              guid: "chef_server_guid#{chef_server_index}",
              cookbook: "chef_server_cookbook#{chef_server_index}",
              bastion: "bastion#{chef_server_index}"
            )
            expect(chef).to have_received(:provision).once.with(
              sub_domain: "bastion_sub_domain#{chef_server_index}",
              guid: "bastion_guid#{chef_server_index}",
              cookbook: "bastion_cookbook#{chef_server_index}",
              bastion: "bastion#{chef_server_index}"
            )
            expect(chef).to have_received(:provision).once.with(
              sub_domain: "nat_sub_domain#{chef_server_index}",
              guid: "nat_guid#{chef_server_index}",
              cookbook: "nat_cookbook#{chef_server_index}",
              bastion: "bastion#{chef_server_index}"
            )
            expect(chef).to have_received(:provision).once.with(
              sub_domain: "instance_sub_domain#{chef_server_index}",
              guid: "instance_guid#{chef_server_index}",
              cookbook: "instance_cookbook#{chef_server_index}",
              bastion: "bastion#{chef_server_index}"
            )
          end
        end
      end
    end
  end

  describe '#destroy' do
    before(:each) do
      allow(@s3_configuration).to receive(:destroy)
      allow(@s3_cloud_formation_template).to receive(:destroy)
      allow(@s3_chef_server_cert).to receive(:destroy)
      allow(@cloud_formation).to receive(:destroy)
      @formatron.destroy
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
      (0..2).each do |vpc_index|
        (0..2).each do |subnet_index|
          subnet_index = "#{vpc_index}_#{subnet_index}"
          (0..2).each do |chef_server_index|
            chef_server_index = "#{subnet_index}_#{chef_server_index}"
            expect(@s3_chef_server_cert).to have_received(:destroy).once.with(
              aws: @aws,
              bucket: @bucket,
              name: @name,
              target: @target,
              guid: "chef_server_guid#{chef_server_index}"
            )
          end
        end
      end
    end

    context 'when an error occurs deleting the Chef Server ' \
            'certificate and key from S3' do
      it 'should continue' do
        allow(@s3_chef_server_cert).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should delete the Chef Server user and organization keys from S3' do
      (0..2).each do |vpc_index|
        (0..2).each do |subnet_index|
          subnet_index = "#{vpc_index}_#{subnet_index}"
          (0..2).each do |chef_server_index|
            chef_server_index = "#{subnet_index}_#{chef_server_index}"
            expect(@s3_chef_server_keys).to have_received(:destroy).once.with(
              aws: @aws,
              bucket: @bucket,
              name: @name,
              target: @target,
              guid: "chef_server_guid#{chef_server_index}"
            )
          end
        end
      end
    end

    context 'when an error occurs deleting the Chef Server ' \
            'user and organization keys from S3' do
      it 'should continue' do
        allow(@s3_chef_server_keys).to receive(:destroy) { fail 'error' }
        @formatron.destroy
      end
    end

    it 'should cleanup the Chef Server configuration for the instances' do
      (0..2).each do |vpc_index|
        vpc_chef_clients = @chef_clients[vpc_index]
        (0..2).each do |subnet_index|
          subnet_chef_clients = vpc_chef_clients[subnet_index]
          subnet_index = "#{vpc_index}_#{subnet_index}"
          (0..2).each do |chef_server_index|
            chef = subnet_chef_clients[chef_server_index]
            chef_server_index = "#{subnet_index}_#{chef_server_index}"
            expect(chef).to have_received :delete_databag
            expect(chef).to have_received(:destroy).once.with(
              guid: "chef_server_guid#{chef_server_index}"
            )
            expect(chef).to have_received(:destroy).once.with(
              guid: "bastion_guid#{chef_server_index}"
            )
            expect(chef).to have_received(:destroy).once.with(
              guid: "nat_guid#{chef_server_index}"
            )
            expect(chef).to have_received(:destroy).once.with(
              guid: "instance_guid#{chef_server_index}"
            )
          end
        end
      end
    end

    context 'when an error occurs cleaning up the Chef Server ' \
            'configuration for the instances' do
      it 'should continue' do
        (0..2).each do |vpc_index|
          vpc_chef_clients = @chef_clients[vpc_index]
          (0..2).each do |subnet_index|
            subnet_chef_clients = vpc_chef_clients[subnet_index]
            (0..2).each do |chef_server_index|
              chef = subnet_chef_clients[chef_server_index]
              allow(chef).to receive(:destroy) { fail 'error' }
            end
          end
        end
        @formatron.destroy
      end
    end

    context 'when an error occurs cleaning up the Chef Server ' \
            'data bags' do
      it 'should continue' do
        (0..2).each do |vpc_index|
          vpc_chef_clients = @chef_clients[vpc_index]
          (0..2).each do |subnet_index|
            subnet_chef_clients = vpc_chef_clients[subnet_index]
            (0..2).each do |chef_server_index|
              chef = subnet_chef_clients[chef_server_index]
              allow(chef).to receive(:delete_databag) { fail 'error' }
            end
          end
        end
        @formatron.destroy
      end
    end
  end
end
