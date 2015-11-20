require_relative 'path'
require 'formatron/logger'

class Formatron
  module S3
    # manage the CloudFormation template stored on S3
    module CloudFormationTemplate
      FILE_NAME = 'cloud_formation_template.json'

      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength
      def self.deploy(
        aws:, kms_key:, bucket:, name:, target:, cloud_formation_template:
      )
        key = Path.key(
          name: name,
          target: target,
          sub_key: FILE_NAME
        )
        Formatron::LOG.info do
          "Upload CloudFormation template to #{bucket}/#{key}"
        end
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: key,
          content: cloud_formation_template
        )
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/ParameterLists

      def self.exists?(aws:, bucket:, name:, target:)
        key = Path.key(
          name: name,
          target: target,
          sub_key: FILE_NAME
        )
        aws.file_exists?(
          bucket: bucket,
          key: key
        )
      end

      # rubocop:disable Metrics/MethodLength
      def self.destroy(aws:, bucket:, name:, target:)
        key = Path.key(
          name: name,
          target: target,
          sub_key: FILE_NAME
        )
        Formatron::LOG.info do
          "Delete CloudFormation template from #{bucket}/#{key}"
        end
        aws.delete_file(
          bucket: bucket,
          key: key
        )
      end
      # rubocop:enable Metrics/MethodLength

      def self.url(region:, bucket:, name:, target:)
        Path.url(
          region: region,
          bucket: bucket,
          name: name,
          target: target,
          sub_key: FILE_NAME
        )
      end
    end
  end
end
