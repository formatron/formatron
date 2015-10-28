class Formatron
  # manage the CloudFormation template stored on S3
  module S3CloudFormationTemplate
    def self.deploy(aws, configuration, target)
      aws.upload(
        configuration.kms_key(target),
        configuration.bucket(target),
        S3Path.path(configuration, target, 'cloud_formation_template.json'),
        configuration.cloud_formation_template(target)
      )
    end

    def self.destroy(aws, configuration, target)
      aws.delete(
        configuration.bucket(target),
        S3Path.path(configuration, target, 'cloud_formation_template.json')
      )
    end
  end
end
