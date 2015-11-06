require_relative 'bootstrap/formatronfile'
require_relative 'bootstrap/config'
require_relative 'bootstrap/ssl'
require_relative 'bootstrap/cookbook'
require_relative 'bootstrap/readme'
require_relative 'bootstrap/gitignore'
require_relative 'bootstrap/ec2'

class Formatron
  module Generators
    # generates a bootstrap configuration
    module Bootstrap
      def self.validate_target_params(targets)
        targets.each do |_, params|
          fail 'target should have :protect parameter' if params[:protect].nil?
        end
      end

      def self.validate_hash_params(hash, params)
        params.each do |param|
          fail "params should contain #{param}" if hash[param].nil?
        end
      end

      # rubocop:disable Metrics/MethodLength
      def self.validate_params(params)
        validate_hash_params params, [
          :name,
          :s3_bucket,
          :kms_key,
          :ec2_key_pair,
          :hosted_zone_id,
          :hosted_zone_id,
          :targets,
          :availability_zone,
          :chef_server
        ]
        validate_hash_params params[:chef_server], [
          :organization,
          :username,
          :email,
          :first_name,
          :last_name,
          :password
        ]
        validate_target_params params[:targets]
      end
      # rubocop:enable Metrics/MethodLength

      def self.generate_targets(directory, targets, cookbooks_bucket_prefix)
        targets.each do |target, params|
          Config.write(
            directory,
            target,
            params[:protect],
            cookbooks_bucket_prefix
          )
          SSL.write directory, target
        end
      end

      def self.generate_cookbooks(directory)
        Cookbook.write(
          directory,
          'chef_server_instance',
          'Chef Server instance'
        )
        Cookbook.write directory, 'nat_instance', 'NAT instance'
        Cookbook.write directory, 'bastion_instance', 'Bastion instance'
      end

      # rubocop:disable Metrics/MethodLength
      def self.generate(directory, params)
        validate_params params
        Readme.write directory, params[:name]
        Gitignore.write directory
        Formatronfile.write directory, params
        Config.write directory
        EC2.write directory
        generate_targets(
          directory,
          params[:targets],
          params[:chef_server][:cookbooks_bucket_prefix]
        )
        generate_cookbooks directory
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
