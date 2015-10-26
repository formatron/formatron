require 'formatron/aws'
require 'formatron/formatronfile'
require 'formatron/configuration'
require 'formatron/s3_configuration'
require 'formatron/s3_cloudformation_template'
require 'formatron/cloudformation_stack'
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
    S3CloudformationTemplate.deploy @aws, @formatronfile, target
    CloudformationStack.deploy @aws, @formatronfile, target
  end

  def provision(target)
    ChefInstances.provision @aws, @formatronfile, target
  end

  def destroy(target)
    S3Configuration.destroy @aws, @formatronfile, target
    S3CloudformationTemplate.destroy @aws, @formatronfile, target
    CloudformationStack.destroy @aws, @formatronfile, target
    ChefInstances.destroy @aws, @formatronfile, target
  end
end
