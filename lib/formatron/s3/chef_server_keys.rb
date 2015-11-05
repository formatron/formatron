require_relative 'path'

class Formatron
  module S3
    # manage the Chef Server user and organization keys
    module ChefServerKeys
      USER_PEM_NAME = 'user.pem'
      ORGANIZATION_PEM_NAME = 'organization.pem'

      # rubocop:disable Metrics/MethodLength
      def self.get(
        aws:,
        bucket:,
        name:,
        target:,
        directory:
      )
        aws.download_file(
          bucket: bucket,
          key: user_pem_key(
            name: name,
            target: target
          ),
          path: user_pem_path(directory: directory)
        )
        aws.download_file(
          bucket: bucket,
          key: organization_pem_key(
            name: name,
            target: target
          ),
          path: organization_pem_path(directory: directory)
        )
      end
      # rubocop:enable Metrics/MethodLength

      def self.user_pem_key(name:, target:)
        Path.key(
          name: name,
          target: target,
          sub_key: USER_PEM_NAME
        )
      end

      def self.user_pem_path(directory:)
        File.join directory, USER_PEM_NAME
      end

      def self.organization_pem_key(name:, target:)
        Path.key(
          name: name,
          target: target,
          sub_key: ORGANIZATION_PEM_NAME
        )
      end

      def self.organization_pem_path(directory:)
        File.join directory, ORGANIZATION_PEM_NAME
      end
    end
  end
end
