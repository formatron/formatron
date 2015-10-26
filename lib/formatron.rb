require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_configuration'
require 'formatron/s3_cloud_formation_template'
require 'formatron/cloud_formation_stack'
require 'formatron/chef_instances'

# manages a Formatron stack
class Formatron
  def initialize(credentials, directory)
    @aws = AWS.new credentials
    @configuration = Configuration.new directory
  end

  def targets
    @configuration.targets
  end

  def protected?(target)
    @configuration.protected? target
  end

  def deploy(target)
    S3Configuration.deploy @aws, @configuration, target
    S3CloudFormationTemplate.deploy @aws, @configuration, target
    CloudFormationStack.deploy @aws, @configuration, target
  end

  def provision(target)
    ChefInstances.provision @aws, @configuration, target
  end

  def destroy(target)
    S3Configuration.destroy @aws, @configuration, target
    S3CloudFormationTemplate.destroy @aws, @configuration, target
    CloudFormationStack.destroy @aws, @configuration, target
    ChefInstances.destroy @aws, @configuration, target
  end
end
