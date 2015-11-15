require 'formatron/aws'
require 'formatron/config'
require 'formatron/dsl'
require 'formatron/s3/configuration'
require 'formatron/s3/chef_server_cert'
require 'formatron/s3/chef_server_keys'
require 'formatron/s3/cloud_formation_template'
require 'formatron/cloud_formation/template'
require 'formatron/cloud_formation'
require 'formatron/chef'
require 'formatron/logger'

# manages a Formatron stack
# rubocop:disable Metrics/ClassLength
class Formatron
  FORMATRONFILE = 'Formatronfile'

  attr_reader :protected
  alias_method :protected?, :protected

  # rubocop:disable Metrics/MethodLength
  def initialize(credentials:, directory:, target:)
    @target = target
    @aws = AWS.new credentials: credentials
    @config = Config.target(
      directory: directory,
      target: target
    )
    @external = External.new(
      target: @target,
      config: @config,
      aws: @aws
    )
    @dsl = DSL.new(
      file: File.join(directory, FORMATRONFILE),
      config: @config,
      target: @target,
      external: @external
    )
    _initialize
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize
    @formatron = @dsl.formatron
    _initialize_instances
    @name = @formatron.name
    @bucket = @formatron.bucket
    global = @formatron.global
    ec2 = global.ec2
    key_pair = ec2.key_pair
    @ec2_key = ec2.private_key
    @protected = global.protect
    @kms_key = global.kms_key
    hosted_zone_id = global.hosted_zone_id
    @hosted_zone_name = @aws.hosted_zone_name hosted_zone_id
    @cloud_formation_template = CloudFormation::Template.new(
      formatron: @formatron,
      hosted_zone_name: @hosted_zone_name,
      key_pair: key_pair,
      kms_key: @kms_key,
      nats: @nats,
      hosted_zone_id: hosted_zone_id,
      target: @target
    ).hash
    _initialize_chef_clients
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize_instances
    @instances = {}
    @chef_servers = {}
    @bastions = {}
    @nats = {}
    @all_instances = {}
    @formatron.vpc.each do |key, vpc|
      nats = @nats[key] = {}
      bastions = @bastions[key] = {}
      chef_servers = @chef_servers[key] = {}
      instances = @instances[key] = {}
      all_instances = @all_instances[key] = {}
      vpc.subnet.values.each do |subnet|
        nats.merge! subnet.nat
        bastions.merge! subnet.bastion
        chef_servers.merge! subnet.chef_server
        instances.merge! subnet.instance
      end
      all_instances.merge! nats
      all_instances.merge! bastions
      all_instances.merge! chef_servers
      all_instances.merge! instances
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize_chef_clients
    @chef_clients = {}
    @chef_servers.each do |vpc_key, chef_servers|
      chef_clients = @chef_clients[vpc_key] = {}
      bastions = @bastions[vpc_key]
      bastions = Hash[bastions.map { |k, v| [k, v.sub_domain] }]
      chef_servers.each do |key, chef_server|
        chef_clients[key] = Chef.new(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          username: chef_server.username,
          organization: chef_server.organization.short_name,
          ssl_verify: chef_server.ssl_verify,
          chef_sub_domain: chef_server.sub_domain,
          ec2_key: @ec2_key,
          bastions: bastions,
          hosted_zone_name: @hosted_zone_name,
          server_stack: @name,
          guid: chef_server.guid
        )
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def deploy
    _deploy_configuration
    _deploy_chef_server_certs
    _deploy_template
    _deploy_stack
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def provision
    @all_instances.each do |key, all_instances|
      chef_clients = @chef_clients[key]
      all_instances.values.each do |instance|
        dsl_chef = instance.chef
        next if dsl_chef.nil?
        server = dsl_chef.server || chef_clients.keys[0]
        chef = chef_clients[server]
        cookbook = dsl_chef.cookbook
        bastion = dsl_chef.bastion
        sub_domain = instance.sub_domain
        _provision chef, cookbook, sub_domain, bastion
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def _provision(chef, cookbook, sub_domain, bastion)
    chef.init
    chef.provision(
      sub_domain: sub_domain,
      cookbook: cookbook,
      bastion: bastion
    )
  ensure
    chef.unlink
  end

  def destroy
    _destroy_chef_instances
    _destroy_configuration
    _destroy_chef_server_cert
    _destroy_chef_server_keys
    _destroy_template
    _destroy_stack
  end

  def _deploy_configuration
    S3::Configuration.deploy(
      aws: @aws,
      kms_key: @kms_key,
      bucket: @bucket,
      name: @name,
      target: @target,
      config: @config
    )
  end

  # rubocop:disable Metrics/MethodLength
  def _deploy_chef_server_certs
    @chef_servers.values.each do |chef_servers|
      chef_servers.values.each do |chef_server|
        S3::ChefServerCert.deploy(
          aws: @aws,
          kms_key: @kms_key,
          bucket: @bucket,
          name: @name,
          target: @target,
          guid: chef_server.guid,
          cert: chef_server.ssl_cert,
          key: chef_server.ssl_key
        )
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def _deploy_template
    S3::CloudFormationTemplate.deploy(
      aws: @aws,
      kms_key: @kms_key,
      bucket: @bucket,
      name: @name,
      target: @target,
      cloud_formation_template:
        JSON.pretty_generate(@cloud_formation_template)
    )
  end

  def _deploy_stack
    CloudFormation.deploy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  end

  def _destroy_configuration
    S3::Configuration.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  rescue => error
    LOG.warn error
  end

  # rubocop:disable Metrics/MethodLength
  def _destroy_chef_server_cert
    @chef_servers.values.each do |chef_servers|
      chef_servers.values.each do |chef_server|
        S3::ChefServerCert.destroy(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          guid: chef_server.guid
        )
      end
    end
  rescue => error
    LOG.warn error
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def _destroy_chef_server_keys
    @chef_servers.values.each do |chef_servers|
      chef_servers.values.each do |chef_server|
        S3::ChefServerKeys.destroy(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          guid: chef_server.guid
        )
      end
    end
  rescue => error
    LOG.warn error
  end
  # rubocop:enable Metrics/MethodLength

  def _destroy_template
    S3::CloudFormationTemplate.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  rescue => error
    LOG.warn error
  end

  def _destroy_stack
    CloudFormation.destroy(
      aws: @aws,
      name: @name,
      target: @target
    )
  rescue => error
    LOG.warn error
  end

  def _destroy_chef_instances
    @all_instances.each do |key, all_instances|
      chef_clients = @chef_clients[key]
      all_instances.values.each do |instance|
        dsl_chef = instance.chef
        next if dsl_chef.nil?
        chef = chef_clients[dsl_chef.server]
        sub_domain = instance.sub_domain
        _destroy_chef_instance chef, sub_domain
      end
    end
  end

  def _destroy_chef_instance(chef, sub_domain)
    chef.init
    chef.destroy(
      sub_domain: sub_domain
    )
  rescue => error
    LOG.warn error
  ensure
    chef.unlink
  end

  private(
    :_initialize,
    :_initialize_instances,
    :_initialize_chef_clients,
    :_deploy_configuration,
    :_deploy_template,
    :_deploy_stack,
    :_destroy_configuration,
    :_destroy_template,
    :_destroy_stack,
    :_destroy_chef_instances,
    :_destroy_chef_instance,
    :_provision
  )
end
# rubocop:enable Metrics/ClassLength
