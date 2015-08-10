AWS_DEPLOY_FILE = 'AwsDeployFile'
CONFIG = 'config'

DEFAULT_CONFIG = '_default'
DEFAULT_CONFIG_DIR = File.join(CONFIG, DEFAULT_CONFIG)
DEFAULT_JSON = "#{DEFAULT_CONFIG}.json"

require_relative 'config/reader'
require_relative 'config/cloudformation'
require 'aws-sdk'
require 'deep_merge'

class AwsDeploy
  class Config

    attr_reader :config, :target, :_cloudformation, :dependencies

    def initialize (dir, target, credentials)
      aws_deploy_file = File.join(dir, AWS_DEPLOY_FILE)
      target_config_dir = File.join(dir, CONFIG, target)
      default_config_dir = File.join(dir, DEFAULT_CONFIG_DIR)
      default_config = File.directory?(default_config_dir) ? AwsDeploy::Config::Reader.read(default_config_dir, DEFAULT_JSON) : {}
      target_config = File.directory?(target_config_dir) ? AwsDeploy::Config::Reader.read(target_config_dir, DEFAULT_JSON) : {}
      @config = default_config.deep_merge!(target_config)
      @target = target
      @credentials = credentials
      @name = nil
      @s3_bucket = nil
      @region = nil
      @prefix = nil
      @_cloudformation = nil
      @dependencies = {}
      @kms_key = {}
      instance_eval(File.read(aws_deploy_file), aws_deploy_file)
    end

    def name (name = nil)
      @name = name unless name.nil?
      @name
    end

    def s3_bucket (s3_bucket = nil)
      @s3_bucket = s3_bucket unless s3_bucket.nil?
      @s3_bucket
    end

    def region (region = nil)
      @region = region unless region.nil?
      @region
    end

    def prefix (prefix = nil)
      @prefix = prefix unless prefix.nil?
      @prefix
    end

    def kms_key (target, key_id = nil)
      @kms_key[target] = key_id unless key_id.nil?
      @kms_key[target]
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
      @config = base.deep_merge!(config)
    end

    def depends (stack_name)
      full_stack_name = "#{prefix}-#{stack_name}-#{target}"
      cloudformation = Aws::CloudFormation::Client.new(
        region: region,
        credentials: @credentials
      )
      response = cloudformation.describe_stacks(
        stack_name: full_stack_name
      )
      stack = response.stacks[0]
      fail "Stack dependency not ready: #{full_stack_name}" unless ['CREATE_COMPLETE', 'ROLLBACK_COMPLETE', 'UPDATE_COMPLETE', 'UPDATE_ROLLBACK_COMPLETE'].include? stack.stack_status
      outputs = @dependencies[stack_name] = {}
      stack.outputs.each do |output|
        outputs[output.output_key] = output.output_value
      end
    end

    def cloudformation (&block)
      @_cloudformation = AwsDeploy::Config::Cloudformation.new(config, dependencies, &block)
    end

  end
end
