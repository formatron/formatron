require_relative 'instance'
require 'formatron/s3/chef_server_cert'
require 'formatron/s3/chef_server_keys'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation Chef Server resources
          class ChefServer
            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/ParameterLists
            def initialize(
              chef_server:,
              key_pair:,
              availability_zone:,
              subnet_guid:,
              hosted_zone_name:,
              vpc_guid:,
              vpc_cidr:,
              kms_key:,
              private_hosted_zone_id:,
              public_hosted_zone_id:,
              bucket:,
              name:,
              target:
            )
              @chef_server = chef_server
              @bucket = bucket
              guid = @chef_server.guid
              @ssl_cert_key = S3::ChefServerCert.cert_key(
                name: name,
                target: target,
                guid: guid
              )
              @ssl_key_key = S3::ChefServerCert.key_key(
                name: name,
                target: target,
                guid: guid
              )
              @user_pem_key = S3::ChefServerKeys.user_pem_key(
                name: name,
                target: target,
                guid: guid
              )
              @organization_pem_key =
                S3::ChefServerKeys.organization_pem_key(
                  name: name,
                  target: target,
                  guid: guid
                )
              _add_ssl_cert_policy
              _add_keys_policy
              # TODO: add extra security group rules
              # TODO: add extra setup variables
              # TODO: add extra setup script
              @instance = Instance.new(
                instance: chef_server,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: vpc_guid,
                vpc_cidr: vpc_cidr,
                kms_key: kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: @bucket,
                name: name,
                target: target
              )
            end
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/MethodLength

            def _add_ssl_cert_policy
              @chef_server.policy do |policy|
                policy.statement do |statement|
                  statement.action 's3:GetObject'
                  statement.resource "arn:aws:s3:::#{@bucket}/#{@ssl_cert_key}"
                  statement.resource "arn:aws:s3:::#{@bucket}/#{@ssl_key_key}"
                end
              end
            end

            def _add_keys_policy
              @chef_server.policy do |policy|
                policy.statement do |statement|
                  statement.action 's3:PutObject'
                  statement.resource "arn:aws:s3:::#{@bucket}/#{@user_pem_key}"
                  statement.resource(
                    "arn:aws:s3:::#{@bucket}/#{@organization_pem_key}"
                  )
                end
              end
            end

            def merge(resources:, outputs:)
              # TODO: add user and cookbooks bucket policy
              @instance.merge resources: resources, outputs: outputs
            end

            private(
              :_add_ssl_cert_policy,
              :_add_keys_policy
            )
          end
        end
      end
    end
  end
end
