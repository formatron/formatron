require 'formatron/s3_configuration'
require 'formatron/s3_chef_server_cert'
require 'formatron/s3_chef_server_keys'
require_relative 'formatronfile/dsl'
require_relative 'formatronfile/cloud_formation/bootstrap_template'

class Formatron
  class Configuration
    # Processes the Formatronfile in the context of the given target
    class Formatronfile
      attr_reader(
        :hosted_zone_id,
        :hosted_zone_name,
        :target,
        :name,
        :bucket,
        :kms_key,
        :cloud_formation_template,
        :chef_server_ssl_cert,
        :chef_server_ssl_key
      )

      def initialize(aws:, config:, target:, directory:)
        @aws = aws
        @target = target
        @config = config
        @directory = directory
        _initialize_dsl
        _initialize_bootstrap unless @dsl.bootstrap.nil?
      end

      def protected?
        @protect
      end

      def _initialize_dsl
        @dsl = DSL.new(
          aws: @aws,
          config: @config,
          target: @target,
          file: File.join(@directory, 'Formatronfile')
        )
        @name = @dsl.name
        @bucket = @dsl.bucket
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def _initialize_bootstrap
        _initialize_properties @dsl.bootstrap
        @chef_server_ssl_cert = @dsl.bootstrap.chef_server.ssl_cert
        @chef_server_ssl_key = @dsl.bootstrap.chef_server.ssl_key
        @cloud_formation_template = CloudFormation::BootstrapTemplate.json(
          bootstrap: @dsl.bootstrap,
          hosted_zone_id: @hosted_zone_id,
          hosted_zone_name: @hosted_zone_name,
          bucket: @bucket,
          config_key: S3Configuration.key(
            target: @target,
            name: @name
          ),
          user_pem_key: S3ChefServerKeys.user_pem_key(
            target: @target,
            name: @name
          ),
          organization_pem_key: S3ChefServerKeys.organization_pem_key(
            target: @target,
            name: @name
          ),
          ssl_cert_key: S3ChefServerCert.cert_key(
            target: @target,
            name: @name
          ),
          ssl_key_key: S3ChefServerCert.key_key(
            target: @target,
            name: @name
          )
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def _initialize_properties(source)
        @kms_key = source.kms_key
        @protect = source.protect
        @hosted_zone_id = source.hosted_zone_id
        @hosted_zone_name = @aws.hosted_zone_name @hosted_zone_id
      end

      private(
        :_initialize_dsl,
        :_initialize_bootstrap,
        :_initialize_properties
      )
    end
  end
end
