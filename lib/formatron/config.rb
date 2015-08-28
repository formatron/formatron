FORMATRON_FILE = 'Formatronfile'
CONFIG = 'config'

DEFAULT_CONFIG = '_default'
DEFAULT_CONFIG_DIR = File.join(CONFIG, DEFAULT_CONFIG)
DEFAULT_JSON = "#{DEFAULT_CONFIG}.json"

require_relative 'config/reader'
require_relative 'config/cloudformation'
require_relative 'config/opscode'
require 'aws-sdk'
require 'deep_merge'

class Formatron
  class Config
    CLOUDFORMATION_DIR = 'cloudformation'

    attr_reader :config

    def initialize(dir, target, credentials)
      @dir = dir
      @credentials = credentials
      @config = {}
      config['formatronTarget'] = target
      @cloudformation = nil
      @opscode = nil
      formatron_file = File.join(@dir, FORMATRON_FILE)
      instance_eval(File.read(formatron_file), formatron_file)
    end

    def name(name = nil)
      unless name.nil?
        config['formatronName'] = name
        # rubocop:disable Metrics/LineLength
        config['formatronConfigS3Key'] = "#{config['formatronTarget']}/#{config['formatronName']}/config.json"
        config['formatronCloudformationS3Key'] =
          "#{config['formatronTarget']}/#{config['formatronName']}/cloudformation"
        config['formatronOpsworksS3Key'] = "#{config['formatronTarget']}/#{config['formatronName']}/opsworks"
        config['formatronOpscodeS3Key'] = "#{config['formatronTarget']}/#{config['formatronName']}/opscode"
        # rubocop:enable Metrics/LineLength
        target_config_dir = File.join(@dir, CONFIG, config['formatronTarget'])
        default_config_dir = File.join(@dir, DEFAULT_CONFIG_DIR)
        default_config =
          if File.directory?(default_config_dir)
            Formatron::Config::Reader.read(default_config_dir, DEFAULT_JSON)
          else
            {}
          end
        target_config =
          if File.directory?(target_config_dir)
            Formatron::Config::Reader.read(target_config_dir, DEFAULT_JSON)
          else
            {}
          end
        config[config['formatronName']] =
          default_config.deep_merge!(target_config)
        config[config['formatronName']]['formatronOutputs'] =
          {} if File.directory?(File.join(@dir, CLOUDFORMATION_DIR))
      end
      config['formatronName']
    end

    def s3_bucket(s3_bucket = nil)
      config['formatronS3Bucket'] = s3_bucket unless s3_bucket.nil?
      config['formatronS3Bucket']
    end

    def region(region = nil)
      config['formatronRegion'] = region unless region.nil?
      config['formatronRegion']
    end

    def prefix(prefix = nil)
      config['formatronPrefix'] = prefix unless prefix.nil?
      config['formatronPrefix']
    end

    def kms_key(target = nil, key_id = nil)
      unless key_id.nil?
        if target == config['formatronTarget']
          config['formatronKmsKey'] = key_id
        end
      end
      config['formatronKmsKey']
    end

    def depends(stack_name)
      dep = Formatron::Config::Depends.new(@credentials)
      @config = dep.load prefix, stack_name, config['formatronTarget'], config
    end

    def cloudformation(&block)
      @cloudformation = Formatron::Config::Cloudformation.new(
        config,
        &block
      ) if block_given?
      @cloudformation
    end

    def opscode(&block)
      @opscode = Formatron::Config::Opscode.new(
        config,
        &block
      ) if block_given?
      @opscode
    end
  end
end
