require 'formatron/s3/chef_server_keys'

class Formatron
  class Chef
    # Download the Chef Server keys
    class Keys
      # rubocop:disable Metrics/ParameterLists
      def initialize(aws:, bucket:, name:, target:, guid:, ec2_key:)
        @aws = aws
        @bucket = bucket
        @name = name
        @target = target
        @guid = guid
        @ec2_key = ec2_key
      end
      # rubocop:enable Metrics/ParameterLists

      def init
        @directory = Dir.mktmpdir 'formatron-chef-server-keys-'
        S3::ChefServerKeys.get(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          guid: @guid,
          directory: @directory
        )
        File.write ec2_key, @ec2_key
      end

      def user_key
        S3::ChefServerKeys.user_pem_path directory: @directory
      end

      def organization_key
        S3::ChefServerKeys.organization_pem_path directory: @directory
      end

      def ec2_key
        File.join @directory, 'ec2_key'
      end

      def unlink
        FileUtils.rm_rf @directory unless @directory.nil?
      end
    end
  end
end
