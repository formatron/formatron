require_relative 's3/cloud_formation_template'

class Formatron
  # manage the CloudFormation stack
  module CloudFormation
    def self.deploy(aws:, bucket:, name:, target:)
      aws.deploy_stack(
        stack_name: _stack_name(name, target),
        template_url: S3::CloudFormationTemplate.url(
          region: aws.region,
          bucket: bucket,
          name: name,
          target: target
        )
      )
    end

    def self.destroy(aws:, name:, target:)
      aws.delete_stack _stack_name(name, target)
    end

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
