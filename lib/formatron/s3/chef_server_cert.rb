require_relative 'path'

class Formatron
  module S3
    # manage the Chef Server SSL certificate and key stored on S3
    module ChefServerCert
      CERT_NAME = 'ssl.cert'
      KEY_NAME = 'ssl.key'

      # rubocop:disable Metrics/ParameterLists
      # rubocop:disable Metrics/MethodLength
      def self.deploy(
        aws:,
        kms_key:,
        bucket:,
        name:,
        target:,
        cert:,
        key:
      )
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: cert_key(
            name: name,
            target: target
          ),
          content: cert
        )
        aws.upload_file(
          kms_key: kms_key,
          bucket: bucket,
          key: key_key(
            name: name,
            target: target
          ),
          content: key
        )
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/ParameterLists

      # rubocop:disable Metrics/MethodLength
      def self.destroy(aws:, bucket:, name:, target:)
        aws.delete_file(
          bucket: bucket,
          key: cert_key(
            name: name,
            target: target
          )
        )
        aws.delete_file(
          bucket: bucket,
          key: key_key(
            name: name,
            target: target
          )
        )
      end
      # rubocop:enable Metrics/MethodLength

      def self.cert_key(name:, target:)
        Path.key(
          name: name,
          target: target,
          sub_key: CERT_NAME
        )
      end

      def self.key_key(name:, target:)
        Path.key(
          name: name,
          target: target,
          sub_key: KEY_NAME
        )
      end
    end
  end
end
