require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_path'
require 'formatron/s3_configuration'
require 'formatron/s3_cloud_formation_template'
require 'formatron/cloud_formation_stack'
require 'formatron/chef_instances'

# manages a Formatron stack
class Formatron
  def initialize(credentials, directory)
    @aws = AWS.new credentials
    @configuration = Configuration.new @aws, directory
  end

  def targets
    @configuration.targets
  end

  def protected?(target)
    @configuration.protected? target
  end

  def deploy(target)
    _deploy_configuration target
    _deploy_template target
    _deploy_stack target
  end

  def provision(target)
    ChefInstances.provision(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def destroy(target)
    _destroy_configuration target
    _destroy_template target
    _destroy_stack target
    _destroy_instances target
  end

  def _deploy_configuration(target)
    S3Configuration.deploy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _deploy_template(target)
    S3CloudFormationTemplate.deploy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _deploy_stack(target)
    CloudFormationStack.deploy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _destroy_configuration(target)
    S3Configuration.destroy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _destroy_template(target)
    S3CloudFormationTemplate.destroy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _destroy_stack(target)
    CloudFormationStack.destroy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  def _destroy_instances(target)
    ChefInstances.destroy(
      aws: @aws,
      configuration: @configuration,
      target: target
    )
  end

  private(
    :_deploy_configuration,
    :_deploy_template,
    :_deploy_stack,
    :_destroy_configuration,
    :_destroy_template,
    :_destroy_stack,
    :_destroy_instances
  )
end
