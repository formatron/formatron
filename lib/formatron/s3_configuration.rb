require 'formatron/s3_path'

class Formatron
  # manage the configuration stored on S3
  module S3Configuration
    def self.deploy(aws, configuration, target)
      aws.upload(
        configuration.kms_key(target),
        configuration.bucket(target),
        S3Path.path(configuration, target, 'config.json'),
        configuration.config(target).to_json
      )
    end

    def self.destroy(aws, configuration, target)
      aws.delete(
        configuration.bucket(target),
        S3Path.path(configuration, target, 'config.json')
      )
    end
  end
end
