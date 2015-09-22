require 'formatron/config/reader'
require 'deep_merge'

class Formatron
  class Config
    attr_reader :hash

    DEFAULT_CONFIG = '_default'

    class Error < RuntimeError
    end

    def initialize(params, config_dir, dependencies, hasCloudformation)
      @hash = {}
      @hash['name'] = params[:name]
      @hash['target'] = params[:target]
      @hash['s3Bucket'] = params[:s3_bucket]
      @hash['prefix'] = params[:prefix]
      @hash['kmsKey'] = params[:kms_key]
      @hash['stacks'] = {}
      @hash['stacks'][params[:name]] = {
        'config' => Reader.read(
          File.join(config_dir, DEFAULT_CONFIG),
          "#{DEFAULT_CONFIG}.json"
        ).deep_merge!(
          Reader.read(
            File.join(config_dir, params[:target]),
            "#{DEFAULT_CONFIG}.json"
          )
        ),
        'outputs' => hasCloudformation ? {} : nil
      }
      dependencies.each do |dependency|
        @hash = dependency.hash.deep_merge!(@hash)
      end
    end
  end
end
