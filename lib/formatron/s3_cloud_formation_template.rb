class Formatron
  # manage the CloudFormation template stored on S3
  module S3CloudFormationTemplate
    FILE_NAME = 'cloud_formation_template.json'

    def self.deploy(aws:, configuration:, target:)
      aws.upload_file(
        configuration.kms_key(target),
        configuration.bucket(target),
        S3Path.path(
          configuration: configuration,
          target: target,
          sub_path: FILE_NAME
        ),
        configuration.cloud_formation_template(target)
      )
    end

    def self.destroy(aws:, configuration:, target:)
      aws.delete_file(
        configuration.bucket(target),
        S3Path.path(
          configuration: configuration,
          target: target,
          sub_path: FILE_NAME
        )
      )
    end
  end
end
