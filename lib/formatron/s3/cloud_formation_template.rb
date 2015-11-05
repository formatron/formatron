require_relative 'path'

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
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: Path.key(
            name: name,
            target: target,
            sub_key: FILE_NAME
          ),
          content: cloud_formation_template
        )
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/ParameterLists

      def self.destroy(aws:, bucket:, name:, target:)
        aws.delete_file(
          bucket: bucket,
          key: Path.key(
            name: name,
            target: target,
            sub_key: FILE_NAME
          )
        )
      end

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
