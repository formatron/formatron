require_relative 'path'
require 'formatron/logger'

class Formatron
  module S3
    # manage the configuration stored on S3
    module Configuration
      FILE_NAME = 'config.json'

      # rubocop:disable Metrics/ParameterLists
      def self.deploy(aws:, kms_key:, bucket:, name:, target:, config:)
        key = self.key name: name, target: target
        Formatron::LOG.info do
          "Upload configuration to #{bucket}/#{key}"
        end
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: key,
          content: "#{JSON.pretty_generate(config)}\n"
        )
      end
      # rubocop:enable Metrics/ParameterLists

      def self.destroy(aws:, bucket:, name:, target:)
        key = self.key name: name, target: target
        Formatron::LOG.info do
          "Delete configuration from #{bucket}/#{key}"
        end
        aws.delete_file(
          bucket: bucket,
          key: key
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
