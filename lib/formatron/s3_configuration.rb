require 'formatron/s3_path'

class Formatron
  # manage the configuration stored on S3
  module S3Configuration
    FILE_NAME = 'config.json'

    def self.deploy(aws, configuration, target)
      aws.upload(
        configuration.kms_key(target),
        configuration.bucket(target),
        S3Path.path(
          configuration: configuration,
          target: target,
          sub_path: FILE_NAME
        ),
        configuration.config(target).to_json
      )
    end

    def self.destroy(aws, configuration, target)
      aws.delete(
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
