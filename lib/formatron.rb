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
    @cloud_formation_template = CloudFormation::BootstrapTemplate.json(
      hosted_zone_id: hosted_zone_id,
      hosted_zone_name: @aws.hosted_zone_name(hosted_zone_id),
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
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def deploy
    _deploy_configuration
    _deploy_chef_server_cert unless @chef_ssl_cert.nil?
    _deploy_template
    _deploy_stack
  end

  def provision
  end

  def destroy
    _destroy_configuration
    _destroy_chef_server_cert unless @chef_ssl_cert.nil?
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
  end

  def _destroy_chef_server_cert
    S3::ChefServerCert.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  end

  def _destroy_template
    S3::CloudFormationTemplate.destroy(
      aws: @aws,
      bucket: @bucket,
      name: @name,
      target: @target
    )
  end

  def _destroy_stack
    CloudFormation.destroy(
      aws: @aws,
      name: @name,
      target: @target
    )
  end

  private(
    :_initialize_from_bootstrap,
    :_deploy_configuration,
    :_deploy_template,
    :_deploy_stack,
    :_destroy_configuration,
    :_destroy_template,
    :_destroy_stack
  )
end
# rubocop:enable Metrics/ClassLength
