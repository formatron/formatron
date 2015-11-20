require 'formatron/cloud_formation'

class Formatron
  class External
    # queries and merges CloudFormation outputs for external stacks
    class Outputs
      attr_reader :hash

      def initialize(aws:, target:)
        @aws = aws
        @target = target
        @hash = {}
      end

      def merge(bucket:, dependency:, configuration:)
        @hash.merge! configuration
        @hash.merge! CloudFormation.outputs(
          aws: @aws,
          bucket: bucket,
          name: dependency,
          target: @target
        )
      end
    end
  end
end
