require_relative 's3/cloud_formation_template'
require 'formatron/logger'

class Formatron
  # manage the CloudFormation stack
  module CloudFormation
    # rubocop:disable Metrics/MethodLength
    def self.deploy(aws:, bucket:, name:, target:, parameters:)
      stack_name = _stack_name name, target
      Formatron::LOG.info do
        "Deploy CloudFormation stack: #{stack_name}"
      end
      aws.deploy_stack(
        stack_name: stack_name,
        template_url: S3::CloudFormationTemplate.url(
          region: aws.region,
          bucket: bucket,
          name: name,
          target: target
        ),
        parameters: parameters
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.destroy(aws:, name:, target:)
      stack_name = _stack_name name, target
      Formatron::LOG.info do
        "Destroy CloudFormation stack: #{stack_name}"
      end
      aws.delete_stack stack_name: stack_name
    end

    # rubocop:disable Metrics/MethodLength
    def self.outputs(aws:, bucket:, name:, target:)
      if S3::CloudFormationTemplate.exists?(
        aws: aws,
        bucket: bucket,
        name: name,
        target: target
      )
        stack_name = _stack_name name, target
        Formatron::LOG.info do
          "Query CloudFormation stack outputs: #{stack_name}"
        end
        aws.stack_outputs stack_name: stack_name
      else
        {}
      end
    end
    # rubocop:enable Metrics/MethodLength

    def self.stack_ready!(aws:, name:, target:)
      aws.stack_ready! stack_name: _stack_name(name, target)
    end

    def self._stack_name(name, target)
      "#{name}-#{target}"
    end

    private_class_method(
      :_stack_name
    )
  end
end
