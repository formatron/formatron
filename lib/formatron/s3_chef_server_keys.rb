require 'formatron/s3_path'

class Formatron
  # manage the Chef Server user and organization keys
  module S3ChefServerKeys
    USER_PEM_NAME = 'user.pem'
    ORGANIZATION_PEM_NAME = 'organization.pem'

    # rubocop:disable Metrics/MethodLength
    def self.get(
      aws:,
      bucket:,
      name:,
      target:
    )
      aws.download_file(
        bucket: bucket,
        key: user_pem_key(
          name: name,
          target: target
        )
      )
      aws.download_file(
        bucket: bucket,
        key: organization_pem_key(
          name: name,
          target: target
        )
      )
    end
    # rubocop:enable Metrics/MethodLength

    def self.user_pem_key(name:, target:)
      S3Path.key(
        name: name,
        target: target,
        sub_key: USER_PEM_NAME
      )
    end

    def self.organization_pem_key(name:, target:)
      S3Path.key(
        name: name,
        target: target,
        sub_key: ORGANIZATION_PEM_NAME
      )
    end
  end
end
