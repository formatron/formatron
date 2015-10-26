require 'formatron/aws'
require 'formatron/formatronfile'
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
    @formatronfile = Formatronfile.new directory, @configuration
  end

  def targets
    @formatronfile.targets
  end

  def protected?(target)
    @formatronfile.protected? target
  end

  def deploy(target)
    S3Configuration.deploy @aws, @formatronfile, target
    S3CloudFormationTemplate.deploy @aws, @formatronfile, target
    CloudFormationStack.deploy @aws, @formatronfile, target
  end

  def provision(target)
    ChefInstances.provision @aws, @formatronfile, target
  end

  def destroy(target)
    S3Configuration.destroy @aws, @formatronfile, target
    S3CloudFormationTemplate.destroy @aws, @formatronfile, target
    CloudFormationStack.destroy @aws, @formatronfile, target
    ChefInstances.destroy @aws, @formatronfile, target
  end
end
