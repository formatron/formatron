FORMATRON_FILE = 'Formatronfile'
CONFIG = 'config'

DEFAULT_CONFIG = '_default'
DEFAULT_CONFIG_DIR = File.join(CONFIG, DEFAULT_CONFIG)
DEFAULT_JSON = "#{DEFAULT_CONFIG}.json"

require_relative 'config/reader'
require_relative 'config/cloudformation'
require 'aws-sdk'
require 'deep_merge'

class Formatron
  class Config

    CLOUDFORMATION_DIR = 'cloudformation'

    attr_reader :config, :target, :_cloudformation, :dependencies

    def initialize (dir, target, credentials)
      @dir = dir
      @target = target
      @credentials = credentials
      @config = {}
      @_cloudformation = nil
      formatron_file = File.join(@dir, FORMATRON_FILE)
      instance_eval(File.read(formatron_file), formatron_file)
    end

    def name (name = nil)
      unless name.nil?
        config['formatronName'] = name
        target_config_dir = File.join(@dir, CONFIG, target)
        default_config_dir = File.join(@dir, DEFAULT_CONFIG_DIR)
        default_config = File.directory?(default_config_dir) ? Formatron::Config::Reader.read(default_config_dir, DEFAULT_JSON) : {}
        target_config = File.directory?(target_config_dir) ? Formatron::Config::Reader.read(target_config_dir, DEFAULT_JSON) : {}
        config[name] = default_config.deep_merge!(target_config)
        config[name]['formatronOutputs'] = {} if File.directory?(File.join(@dir, CLOUDFORMATION_DIR))
        init_from_config
      end
      @name
    end

    def s3_bucket (s3_bucket = nil)
      unless s3_bucket.nil?
        config['formatronS3Bucket'] = s3_bucket
        init_from_config
      end
      @s3_bucket
    end

    def region (region = nil)
      unless region.nil?
        config['formatronRegion'] = region
        init_from_config
      end
      @region
    end

    def prefix (prefix = nil)
      unless prefix.nil?
        config['formatronPrefix'] = prefix
        init_from_config
      end
      @prefix
    end

    def kms_key (target = nil, key_id = nil)
      unless key_id.nil?
        if target == @target
          config['formatronKmsKey'] = key_id
          init_from_config
        end
      end
      @kms_key
    end

    def depends (stack_name)
      s3 = Aws::S3::Client.new(
        region: region,
        signature_version: 'v4',
        credentials: @credentials
      )
      response = s3.get_object(
        bucket: s3_bucket,
        key: "#{target}/#{stack_name}/config.json"
      )
      base = JSON.parse(response.body.read)
      @config = base.deep_merge!(config)
      init_from_config
      unless config[stack_name]['formatronOutputs'].nil?
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
        outputs = config[stack_name]['formatronOutputs'] 
        stack.outputs.each do |output|
          outputs[output.output_key] = output.output_value
        end
      end
    end

    def cloudformation (&block)
      @_cloudformation = Formatron::Config::Cloudformation.new(config, &block)
    end

    private

    def init_from_config
      @name = config['formatronName']
      @s3_bucket = config['formatronS3Bucket']
      @region = config['formatronRegion']
      @prefix = config['formatronPrefix']
      @kms_key = config['formatronKmsKey']
    end

  end
end
