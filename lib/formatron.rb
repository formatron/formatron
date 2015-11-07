require 'formatron/aws'
require 'formatron/config'
require 'formatron/formatronfile'
require 'formatron/s3/configuration'
require 'formatron/s3/chef_server_cert'
require 'formatron/s3/chef_server_keys'
require 'formatron/s3/cloud_formation_template'
require 'formatron/cloud_formation'
require 'formatron/cloud_formation/bootstrap_template'
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
    @formatronfile = Formatronfile.new(
      aws: @aws,
      config: @config,
      target: target,
      file: File.join(directory, FORMATRONFILE)
    )
    @name = @formatronfile.name
    @bucket = @formatronfile.bucket
    _initialize_from_bootstrap unless @formatronfile.bootstrap.nil?
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def _initialize_from_bootstrap
    bootstrap = @formatronfile.bootstrap
    @protected = bootstrap.protect
    @kms_key = bootstrap.kms_key
    @chef_ssl_cert = bootstrap.chef_server.ssl_cert
    @chef_ssl_key = bootstrap.chef_server.ssl_key
    hosted_zone_id = bootstrap.hosted_zone_id
    @hosted_zone_name = @aws.hosted_zone_name hosted_zone_id
    @cloud_formation_template = CloudFormation::BootstrapTemplate.json(
      hosted_zone_id: hosted_zone_id,
      hosted_zone_name: @hosted_zone_name,
      bootstrap: bootstrap,
      bucket: @bucket,
      config_key: S3::Configuration.key(
        name: @name, target: @target
      ),
      user_pem_key: S3::ChefServerKeys.user_pem_key(
        name: @name, target: @target
      ),
      organization_pem_key: S3::ChefServerKeys.organization_pem_key(
        name: @name, target: @target
      ),
      ssl_cert_key: S3::ChefServerCert.cert_key(
        name: @name, target: @target
      ),
      ssl_key_key: S3::ChefServerCert.key_key(
        name: @name, target: @target
      )
    )
    bastion = bootstrap.bastion
    nat = bootstrap.nat
    chef_server = bootstrap.chef_server
    @bastion_sub_domain = bastion.sub_domain
    @nat_sub_domain = nat.sub_domain
    @chef_server_sub_domain = chef_server.sub_domain
    @bastion_cookbook = bastion.cookbook
    @nat_cookbook = nat.cookbook
    @chef_server_cookbook = chef_server.cookbook
    @chef = Chef.new(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target,
      username: chef_server.username,
      organization: chef_server.organization.short_name,
      ssl_verify: chef_server.ssl_verify,
      chef_sub_domain: @chef_server_sub_domain,
      private_key: bootstrap.ec2.private_key,
      bastion_sub_domain: @bastion_sub_domain,
      hosted_zone_name: @hosted_zone_name,
      server_stack: @name
    )
  end
  # rubocop:enable Metrics/AbcSize
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
      cloud_formation_template: @cloud_formation_template
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
    :_initialize_from_bootstrap,
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
