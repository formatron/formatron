require 'deep_merge'
require 'formatron/s3/configuration'
require 'formatron/dsl/formatron'
require_relative 'external/dsl'
require_relative 'external/outputs'

class Formatron
  # downloads and merges config from dependencies
  class External
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
        configuration: configuration['dsl']
      )
      @config.deep_merge! configuration['config']
      @config.deep_merge! @local_config
      @outputs.merge dependency: dependency
    end
    # rubocop:enable Metrics/MethodLength
  end
end
