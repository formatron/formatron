require 'formatron/aws'
require 'formatron/config'
require 'formatron/dsl'
require 'formatron/s3/configuration'
require 'formatron/s3/chef_server_cert'
require 'formatron/s3/chef_server_keys'
require 'formatron/s3/cloud_formation_template'
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
    @dsl = DSL.new(
      file: File.join(directory, FORMATRONFILE),
      config: @config,
      target: @target
    )
    _initialize
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize
    @formatron = @dsl.formatron
    _initialize_instances
    bastion = @bastions.values[0]
    @bastion_sub_domain = bastion.sub_domain
    @name = @formatron.name
    @bucket = @formatron.bucket
    global = @formatron.global
    ec2 = global.ec2
    key_pair = ec2.key_pair
    @private_key = ec2.private_key
    @protected = global.protect
    @kms_key = global.kms_key
    hosted_zone_id = global.hosted_zone_id
    @hosted_zone_name = @aws.hosted_zone_name hosted_zone_id
    @cloud_formation_template = CloudFormation::Template.new(
      formatron: @formatron,
      hosted_zone_name: @hosted_zone_name,
      key_pair: key_pair,
      kms_key: @kms_key,
      instances: @all_instances,
      hosted_zone_id: hosted_zone_id
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
    @formatron.vpc.each do |_key, vpc|
      vpc.subnet.each do |_key, subnet|
        @chef_servers.merge! subnet.chef_server
        @bastions.merge! subnet.bastion
        @nats.merge! subnet.nat
        @instances.merge! subnet.instance
      end
    end
    @all_instances = {}
    @all_instances.merge! @chef_servers
    @all_instances.merge! @bastions
    @all_instances.merge! @nats
    @all_instances.merge! @instances
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def _initialize_chef_clients
    @chef_clients = {}
    @chef_servers.each do |key, chef_server|
      @chef_clients[key] = Chef.new(
        aws: @aws,
        bucket: @bucket,
        name: @name,
        target: @target,
        username: chef_server.username,
        organization: chef_server.organization.short_name,
        ssl_verify: chef_server.ssl_verify,
        chef_sub_domain: chef_server.sub_domain,
        private_key: @private_key,
        bastion_sub_domain: @bastion_sub_domain,
        hosted_zone_name: @hosted_zone_name,
        server_stack: @name
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  def deploy
    _deploy_configuration
    _deploy_chef_server_cert unless @chef_ssl_cert.nil?
    _deploy_template
    _deploy_stack
  end

  # rubocop:disable Metrics/MethodLength
  def provision
    @chef.init
    @chef.provision(
      sub_domain: @bastion_sub_domain,
      cookbook: @bastion_cookbook
    )
    @chef.provision(
      sub_domain: @nat_sub_domain,
      cookbook: @nat_cookbook
    )
    @chef.provision(
      sub_domain: @chef_server_sub_domain,
      cookbook: @chef_server_cookbook
    )
  ensure
    @chef.unlink
  end
  # rubocop:enable Metrics/MethodLength

  def destroy
    _destroy_chef_instances
    _destroy_configuration
    _destroy_chef_server_cert unless @chef_ssl_cert.nil?
    _destroy_chef_server_keys unless @chef_ssl_cert.nil?
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

  def _deploy_chef_server_cert
    S3::ChefServerCert.deploy(
      aws: @aws,
      kms_key: @kms_key,
      bucket: @bucket,
      name: @name,
      target: @target,
      cert: @chef_ssl_cert,
      key: @chef_ssl_key
    )
  end

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

  def _destroy_chef_server_cert
    S3::ChefServerCert.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  rescue => error
    LOG.warn error
  end

  def _destroy_chef_server_keys
    S3::ChefServerKeys.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  rescue => error
    LOG.warn error
  end

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

  # rubocop:disable Metrics/MethodLength
  def _destroy_chef_instances
    @chef.init
    @chef.destroy(
      sub_domain: @bastion_sub_domain
    )
    @chef.destroy(
      sub_domain: @nat_sub_domain
    )
    @chef.destroy(
      sub_domain: @chef_server_sub_domain
    )
  rescue => error
    LOG.warn error
  ensure
    @chef.unlink
  end
  # rubocop:enable Metrics/MethodLength

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
    :_destroy_chef_instances
  )
end
# rubocop:enable Metrics/ClassLength
