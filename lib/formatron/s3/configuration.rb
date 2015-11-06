require_relative 'path'

class Formatron
  module S3
    # manage the configuration stored on S3
    module Configuration
      FILE_NAME = 'config.json'

      # rubocop:disable Metrics/ParameterLists
      def self.deploy(aws:, kms_key:, bucket:, name:, target:, config:)
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: key(
            name: name,
            target: target
          ),
          content: "#{JSON.pretty_generate(config)}\n"
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def self.destroy(aws:, bucket:, name:, target:)
        aws.delete_file(
          bucket: bucket,
          key: key(
            name: name,
            target: target
          )
        )
      end

      def self.key(name:, target:)
        Path.key(
          name: name,
          target: target,
          sub_key: FILE_NAME
        )
      end
    end
  end
end