require_relative 'instance/formatronfile'
require_relative 'instance/config'
require_relative 'util/cookbook'
require_relative 'util/readme'
require_relative 'util/gitignore'

class Formatron
  module Generators
    # generates an instance configuration
    module Instance
      def self.validate_hash_params(hash, params)
        params.each do |param|
          fail "params should contain #{param}" if hash[param].nil?
        end
      end

      def self.validate_params(params)
        validate_hash_params params, [
          :name,
          :s3_bucket,
          :bootstrap_configuration,
          :vpc,
          :subnet,
          :targets
        ]
      end

      def self.generate_targets(directory, targets, name)
        targets.each do |target|
          Config.write(
            directory,
            target,
            name
          )
        end
      end

      def self.generate_cookbooks(directory, name)
        Util::Cookbook.write(
          directory,
          "#{name}_instance",
          "#{name} instance"
        )
      end

      # rubocop:disable Metrics/MethodLength
      def self.generate(directory, params)
        validate_params params
        Util::Readme.write directory, params[:name]
        Util::Gitignore.write directory
        Formatronfile.write directory, params
        Config.write directory
        generate_targets(
          directory,
          params[:targets],
          params[:name]
        )
        generate_cookbooks directory, params[:name]
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
