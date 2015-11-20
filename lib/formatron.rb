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
require 'formatron/util/vpc'
require 'formatron/chef_clients'
require 'formatron/external'

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
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def _initialize
    @formatron = @dsl.formatron
    @vpcs = @formatron.vpc
    @name = @formatron.name
    @bucket = @formatron.bucket
    external_formatron = @external.formatron
    @external_vpcs = external_formatron.vpc
    external_global = external_formatron.global
    global = @formatron.global || external_global
    external_ec2 = external_global.ec2
    ec2 = global.ec2 || external_ec2
    key_pair = ec2.key_pair || external_ec2.key_pair
    @ec2_key = ec2.private_key || external_ec2.private_key
    @protected = global.protect || external_global.protect
    @kms_key = global.kms_key || external_global.kms_key
    @databag_secret = global.databag_secret || external_global.databag_secret
    hosted_zone_id = global.hosted_zone_id || external_global.hosted_zone_id
    @hosted_zone_name = @aws.hosted_zone_name hosted_zone_id
    @configuration = @external.export formatron: @formatron
    @cloud_formation_template = CloudFormation::Template.new(
      formatron: @formatron,
      hosted_zone_name: @hosted_zone_name,
      key_pair: key_pair,
      kms_key: @kms_key,
      hosted_zone_id: hosted_zone_id,
      target: @target,
      external: @external
    ).hash
    _initialize_chef_clients
    _initialize_instances
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def _initialize_chef_clients
    @chef_clients = {}
    @vpcs.each do |key, vpc|
      @chef_clients[key] = ChefClients.new(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target,
        ec2_key: @ec2_key,
        hosted_zone_name: @hosted_zone_name,
        vpc: vpc,
        external: @external_vpcs[key],
        configuration: @configuration,
        databag_secret: @databag_secret
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize_instances
    @chef_servers = {}
    @bastions = {}
    @nats = {}
    @instances = {}
    @all_instances = {}
    @vpcs.each do |k, v|
      chef_servers = @chef_servers[k] = {}
      bastions = @bastions[k] = {}
      nats = @nats[k] = {}
      instances = @instances[k] = {}
      all_instances = @all_instances[k] = {}
      v.subnet.values.each do |s|
        chef_servers.merge! s.chef_server
        bastions.merge! s.bastion
        nats.merge! s.nat
        instances.merge! s.instance
      end
      all_instances.merge! chef_servers
      all_instances.merge! bastions
      all_instances.merge! nats
      all_instances.merge! instances
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def deploy
    _deploy_configuration
    _deploy_chef_server_certs
    if @cloud_formation_template[:Resources].empty?
      _destroy_template
      _destroy_stack
    else
      _deploy_template
      _deploy_stack
    end
  end

  def provision
    @all_instances.each do |key, instances|
      _provision_vpc key, instances
    end
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _provision_vpc(key, instances)
    chef_clients = @chef_clients[key]
    chef_clients.init
    chef_clients.deploy_databags
    instances.values.each do |instance|
      dsl_chef = instance.chef
      next if dsl_chef.nil?
      chef = chef_clients.get dsl_chef.server
      cookbook = dsl_chef.cookbook
      bastion = dsl_chef.bastion
      sub_domain = instance.sub_domain
      guid = instance.guid
      _provision_instance chef, cookbook, sub_domain, guid, bastion
    end
  ensure
    chef_clients.unlink
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def _provision_instance(chef, cookbook, sub_domain, guid, bastion)
    chef.provision(
      sub_domain: sub_domain,
      guid: guid,
      cookbook: cookbook,
      bastion: bastion
    )
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
      configuration: @configuration
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
      target: @target,
      parameters: @external.outputs.hash
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
    @all_instances.each do |key, instances|
      _destroy_chef_vpc_instances key, instances
    end
  end

  # rubocop:disable Metrics/MethodLength
  def _destroy_chef_vpc_instances(key, instances)
    chef_clients = @chef_clients[key]
    chef_clients.init
    chef_clients.delete_databags
    instances.values.each do |instance|
      dsl_chef = instance.chef
      next if dsl_chef.nil?
      chef = chef_clients.get dsl_chef.server
      guid = instance.guid
      _destroy_chef_instance chef, guid
    end
  rescue => error
    LOG.warn error
  ensure
    chef_clients.unlink
  end
  # rubocop:enable Metrics/MethodLength

  def _destroy_chef_instance(chef, guid)
    chef.destroy(
      guid: guid
    )
  rescue => error
    LOG.warn error
  end

  private(
    :_initialize,
    :_initialize_chef_clients,
    :_initialize_instances,
    :_deploy_configuration,
    :_deploy_template,
    :_deploy_stack,
    :_destroy_configuration,
    :_destroy_template,
    :_destroy_stack,
    :_destroy_chef_instances,
    :_destroy_chef_vpc_instances,
    :_destroy_chef_instance,
    :_provision_vpc,
    :_provision_instance
  )
end
# rubocop:enable Metrics/ClassLength
