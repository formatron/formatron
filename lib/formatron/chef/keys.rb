require 'formatron/s3_chef_server_keys'

class Formatron
  module Chef
    # Download the Chef Server keys
    class Keys
      def initialize(aws:, bucket:, name:, target:)
        @directory = Dir.mktmpdir 'formatron-chef-server-keys-'
        S3ChefServerKeys.get(
          aws: aws,
          bucket: bucket,
          name: name,
          target: target,
          directory: @directory
        )
      end

      def user_key
        S3ChefServerKeys.user_pem_path directory: @directory
      end

      def organization_key
        S3ChefServerKeys.organization_pem_path directory: @directory
      end
    end
  end
end
