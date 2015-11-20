require 'json'
require 'deep_merge'
require 'formatron/s3/configuration'
require 'formatron/dsl/formatron'
require_relative 'external/dsl'
require_relative 'external/outputs'

class Formatron
  # downloads and merges config from dependencies
  class External
    DSL_KEY = 'dsl'
    CONFIG_KEY = 'config'
    OUTPUTS_KEY = 'outputs'

    attr_reader(
      :formatron,
      :outputs
    )

    def initialize(aws:, target:, config:)
      @aws = aws
      @target = target
      @config = config
      @local_config = Marshal.load Marshal.dump(@config)
      @formatron = Formatron::DSL::Formatron.new external: nil
      @outputs = Outputs.new aws: @aws, target: @target
    end

    # rubocop:disable Metrics/MethodLength
    def merge(bucket:, dependency:)
      configuration = S3::Configuration.get(
        aws: @aws,
        bucket: bucket,
        name: dependency,
        target: @target
      )
      DSL.merge(
        formatron: @formatron,
        configuration: configuration[DSL_KEY]
      )
      @config.deep_merge! configuration[CONFIG_KEY]
      @config.deep_merge! @local_config
      @outputs.merge(
        bucket: bucket,
        dependency: dependency,
        configuration: configuration[OUTPUTS_KEY]
      )
    end
    # rubocop:enable Metrics/MethodLength

    def export(formatron:)
      dsl = DSL.export formatron: @formatron
      local_dsl = DSL.export formatron: formatron
      dsl.deep_merge! local_dsl
      {
        CONFIG_KEY => @config,
        DSL_KEY => dsl,
        OUTPUTS_KEY => @outputs.hash
      }
    end
  end
end
