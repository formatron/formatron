require_relative 'instance'
require 'formatron/s3/chef_server_cert'
require 'formatron/s3/chef_server_keys'
require 'formatron/cloud_formation/resources/iam'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation Chef Server resources
          # rubocop:disable Metrics/ClassLength
          class ChefServer
            USER_PREFIX = 'user'
            ACCESS_KEY_PREFIX = 'accessKey'

            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/ParameterLists
            # rubocop:disable Metrics/AbcSize
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
              @user_id = "#{USER_PREFIX}#{guid}"
              @access_key_id = "#{ACCESS_KEY_PREFIX}#{guid}"
              @kms_key = kms_key
              @username = @chef_server.username
              @password = @chef_server.password
              @first_name = @chef_server.first_name
              @last_name = @chef_server.last_name
              @email = @chef_server.email
              @version = @chef_server.version
              @cookbooks_bucket = @chef_server.cookbooks_bucket
              organization = @chef_server.organization
              @organization_short_name = organization.short_name
              @organization_full_name = organization.full_name
              _set_default_instance_type
              _set_os
              _add_ssl_cert_policy
              _add_keys_policy
              _add_open_ports
              _add_setup_script
              @instance = Instance.new(
                instance: @chef_server,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: vpc_guid,
                vpc_cidr: vpc_cidr,
                kms_key: @kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: @bucket,
                name: name,
                target: target
              )
            end
            # rubocop:enable Metrics/AbcSize
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/MethodLength

            def _set_default_instance_type
              @chef_server.instance_type(
                't2.medium'
              ) if @chef_server.instance_type.nil?
            end

            def _set_os
              @chef_server.os(
                'ubuntu'
              )
            end

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

            def _add_open_ports
              @chef_server.security_group do |security_group|
                security_group.open_tcp_port 80
                security_group.open_tcp_port 443
              end
            end

            # rubocop:disable Metrics/MethodLength
            def _add_setup_script
              @chef_server.setup do |setup|
                scripts = setup.script
                scripts.unshift Scripts.chef_server(
                  username: @username,
                  first_name: @first_name,
                  last_name: @last_name,
                  email: @email,
                  password: @password,
                  organization_short_name: @organization_short_name,
                  organization_full_name: @organization_full_name,
                  bucket: @bucket,
                  user_pem_key: @user_pem_key,
                  organization_pem_key: @organization_pem_key,
                  kms_key: @kms_key,
                  chef_server_version: @version,
                  ssl_cert_key: @ssl_cert_key,
                  ssl_key_key: @ssl_key_key,
                  cookbooks_bucket: @cookbooks_bucket
                )
                setup.variable 'REGION' do |variable|
                  variable.value Template.ref('AWS::Region')
                end
                setup.variable 'ACCESS_KEY_ID' do |variable|
                  variable.value Template.ref(@access_key_id)
                end
                setup.variable 'SECRET_ACCESS_KEY' do |variable|
                  variable.value Template.get_attribute(
                    @access_key_id, 'SecretAccessKey'
                  )
                end
              end
            end
            # rubocop:enable Metrics/MethodLength

            def merge(resources:, outputs:)
              _add_cookbooks_bucket_user resources
              @instance.merge resources: resources, outputs: outputs
            end

            # rubocop:disable Metrics/MethodLength
            def _add_cookbooks_bucket_user(resources)
              resources[@user_id] = Resources::IAM.user(
                policy_name: @user_id,
                statements: [{
                  actions: %w(s3:PutObject s3:GetObject s3:DeleteObject),
                  resources: "arn:aws:s3:::#{@cookbooks_bucket}/*"
                }, {
                  actions: %w(s3:ListBucket),
                  resources: "arn:aws:s3:::#{@cookbooks_bucket}"
                }]
              )
              resources[@access_key_id] = Resources::IAM.access_key(
                user_name: Template.ref(@user_id)
              )
            end
            # rubocop:enable Metrics/MethodLength

            private(
              :_set_default_instance_type,
              :_set_os,
              :_add_ssl_cert_policy,
              :_add_keys_policy,
              :_add_open_ports,
              :_add_setup_script,
              :_add_cookbooks_bucket_user
            )
          end
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
