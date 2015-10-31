require 'formatron/s3_path'
require 'formatron/s3_cloud_formation_template'

class Formatron
  # manage the CloudFormation stack
  module CloudFormationStack
    def self.deploy(aws:, configuration:, target:)
      aws.deploy_stack(
        stack_name: _stack_name(configuration, target),
        template_url: S3Path.url(
          region: aws.region,
          configuration: configuration,
          target: target,
          sub_path: S3CloudFormationTemplate::FILE_NAME
        )
      )
    end

    def self.destroy(aws:, configuration:, target:)
      aws.delete_stack _stack_name(configuration, target)
    end

    def self._stack_name(configuration, target)
      "#{configuration.name(target)}-#{target}"
    end

    private_class_method(
      :_stack_name
    )
  end
end
