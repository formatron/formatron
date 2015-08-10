AWS_DEPLOY_FILE = 'AwsDeployFile'
CONFIG = 'config'

DEFAULT_CONFIG = '_default'
DEFAULT_CONFIG_DIR = File.join(CONFIG, DEFAULT_CONFIG)
DEFAULT_JSON = "#{DEFAULT_CONFIG}.json"

require_relative 'config/reader'
require_relative 'config/cloudformation'
require 'aws-sdk'

class AwsDeploy
  class Config

    attr_accessor :s3_bucket, :region, :name, :prefix
    attr_reader :config, :cloudformation, :target, :kms_key

    def initialize (dir, target, credentials)
      aws_deploy_file = File.join(dir, AWS_DEPLOY_FILE)
      target_config_dir = File.join(dir, CONFIG, target)
      default_config_dir = File.join(dir, DEFAULT_CONFIG_DIR)
      default_config = File.directory?(default_config_dir) ? AwsDeploy::Config::Reader.read(default_config_dir, DEFAULT_JSON) : {}
      target_config = File.directory(target_config_dir) ? AwsDeploy::Config::Reader.read(target_config_dir, DEFAULT_JSON) : {}
      @config = default_config.merge target_config
      @target = target
      @credentials = credentials
      @name = {}
      @s3_bucket = nil
      @region = nil
      @cloudformation = nil
      @kms_key = {}
      instance_eval(File.read(aws_deploy_file), aws_deploy_file)
    end

    def kms_key (target, key_id)
      @kms_key[target] = key_id
    end

    def base_config (base_name)
      s3 = Aws::S3::Client.new(
        region: region,
        signature_version: 'v4',
        credentials: @credentials
      )
      response = s3.get_object(
        bucket: s3_bucket,
        key: "#{target}/#{base_name}/config.json"
      )
      base = JSON.parse(response.body.read)
      @config = base.merge config
    end

    def cloudformation (&block)
      @cloudformation = AwsDeploy::Config::Cloudformation.new(config, &block)
    end

  end
end
