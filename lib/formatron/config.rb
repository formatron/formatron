require 'formatron/config/reader'
require 'deep_merge'

class Formatron
  # loads and merges config
  class Config
    attr_reader :hash

    DEFAULT_CONFIG = '_default'

    class Error < RuntimeError
    end

    def initialize(params, config_dir, dependencies, hasCloudformation)
      @hash = {}
      _set_common_keys params
      _set_this_stack params, config_dir, hasCloudformation
      _set_dependencies dependencies
    end

    def _set_common_keys(params)
      @hash['name'] = params[:name]
      @hash['target'] = params[:target]
      @hash['s3Bucket'] = params[:s3_bucket]
      @hash['prefix'] = params[:prefix]
      @hash['kmsKey'] = params[:kms_key]
    end

    def _set_this_stack(params, config_dir, hasCloudformation)
      @hash['stacks'] = {}
      @hash['stacks'][params[:name]] = {
        'config' => _read_local_config(params, config_dir),
        'outputs' => hasCloudformation ? {} : nil
      }
    end

    def _set_dependencies(dependencies)
      dependencies.each do |dependency|
        @hash = dependency.hash.deep_merge!(@hash)
      end
    end

    def _read_local_config(params, config_dir)
      Reader.read(
        File.join(config_dir, DEFAULT_CONFIG),
        "#{DEFAULT_CONFIG}.json"
      ).deep_merge!(
        Reader.read(
          File.join(config_dir, params[:target]),
          "#{DEFAULT_CONFIG}.json"
        )
      )
    end

    private(
      :_read_local_config,
      :_set_common_keys,
      :_set_this_stack,
      :_set_dependencies
    )
  end
end
