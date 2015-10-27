class Formatron
  # manage the configuration stored on S3
  module S3Configuration
    def self.deploy(aws, configuration, target)
      aws.upload(
        configuration.kms_key(target),
        configuration.bucket(target),
        File.join(target, configuration.name(target), 'config.json'),
        configuration.config(target).to_json
      )
    end

    def self.destroy(_aws, _formatronfile, _target)
    end
  end
end
