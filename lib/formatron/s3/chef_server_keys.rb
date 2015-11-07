require_relative 'path'
require 'formatron/logger'

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
        user_pem_key = self.user_pem_key name: name, target: target
        Formatron::LOG.info do
          'Download Chef Server user key from ' \
          "#{bucket}/#{user_pem_key}"
        end
        aws.download_file(
          bucket: bucket,
          key: user_pem_key,
          path: user_pem_path(directory: directory)
        )
        organization_pem_key = self.organization_pem_key(
          name: name, target: target
        )
        Formatron::LOG.info do
          'Download Chef Server organization key ' \
          "from #{bucket}/#{organization_pem_key}"
        end
        aws.download_file(
          bucket: bucket,
          key: organization_pem_key,
          path: organization_pem_path(directory: directory)
        )
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def self.destroy(
        aws:,
        bucket:,
        name:,
        target:
      )
        user_pem_key = self.user_pem_key name: name, target: target
        Formatron::LOG.info do
          'Delete Chef Server user key from ' \
          "#{bucket}/#{user_pem_key}"
        end
        aws.delete_file(
          bucket: bucket,
          key: user_pem_key
        )
        organization_pem_key = self.organization_pem_key(
          name: name, target: target
        )
        Formatron::LOG.info do
          'Delete Chef Server organization key ' \
          "from #{bucket}/#{organization_pem_key}"
        end
        aws.delete_file(
          bucket: bucket,
          key: organization_pem_key
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
