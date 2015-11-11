require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/chef_server'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # rubocop:disable Metrics/ClassLength
        class Subnet
          describe ChefServer do
            before :each do
              @bucket = 'bucket'
              @ssl_cert_key = 'ssl_cert_key'
              @ssl_key_key = 'ssl_key_key'
              @user_pem_key = 'user_pem_key'
              @organization_pem_key = 'organization_pem_key'
              name = 'name'
              target = 'target'
              guid = 'guid'
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              chef_server_cert_class = class_double(
                'Formatron::S3::ChefServerCert'
              ).as_stubbed_const
              allow(chef_server_cert_class).to receive(
                :cert_key
              ).with(
                name: name,
                target: target,
                guid: guid
              ) { @ssl_cert_key }
              allow(chef_server_cert_class).to receive(
                :key_key
              ).with(
                name: name,
                target: target,
                guid: guid
              ) { @ssl_key_key }
              chef_server_keys_class = class_double(
                'Formatron::S3::ChefServerKeys'
              ).as_stubbed_const
              allow(chef_server_keys_class).to receive(
                :user_pem_key
              ).with(
                name: name,
                target: target,
                guid: guid
              ) { @user_pem_key }
              allow(chef_server_keys_class).to receive(
                :organization_pem_key
              ).with(
                name: name,
                target: target,
                guid: guid
              ) { @organization_pem_key }
              dsl_chef_server = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet::ChefServer'
              )
              dsl_policy = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Policy'
              )
              @dsl_ssl_cert_statement = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Policy::Statement'
              )
              allow(@dsl_ssl_cert_statement).to receive :action
              allow(@dsl_ssl_cert_statement).to receive :resource
              @dsl_keys_statement = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Policy::Statement'
              )
              allow(@dsl_keys_statement).to receive :action
              allow(@dsl_keys_statement).to receive :resource
              dsl_statements = [
                @dsl_ssl_cert_statement,
                @dsl_keys_statement
              ]
              allow(dsl_policy).to receive(:statement) do |&block|
                block.call dsl_statements.shift
              end
              allow(dsl_chef_server).to receive(:policy) do |&block|
                block.call dsl_policy
              end
              allow(dsl_chef_server).to receive(:guid).with(
                no_args
              ) { guid }
              @template_instance = instance_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              )
              template_instance_class = class_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              ).as_stubbed_const
              allow(template_instance_class).to receive(:new).with(
                instance: dsl_chef_server,
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
              ) { @template_instance }
              @template_chef_server = ChefServer.new(
                chef_server: dsl_chef_server,
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

            it 'should add ssl cert policy' do
              expect(@dsl_ssl_cert_statement).to have_received(
                :action
              ).with 's3:GetObject'
              expect(@dsl_ssl_cert_statement).to have_received(
                :resource
              ).with "arn:aws:s3:::#{@bucket}/#{@ssl_cert_key}"
              expect(@dsl_ssl_cert_statement).to have_received(
                :resource
              ).with "arn:aws:s3:::#{@bucket}/#{@ssl_key_key}"
            end

            it 'should add keys policy' do
              expect(@dsl_keys_statement).to have_received(
                :action
              ).with 's3:PutObject'
              expect(@dsl_keys_statement).to have_received(
                :resource
              ).with "arn:aws:s3:::#{@bucket}/#{@user_pem_key}"
              expect(@dsl_keys_statement).to have_received(
                :resource
              ).with "arn:aws:s3:::#{@bucket}/#{@organization_pem_key}"
            end

            describe '#merge' do
              it 'should pass through to the Instance merge method' do
                resources = 'resources'
                outputs = 'outputs'
                expect(@template_instance).to receive(:merge).with(
                  resources: resources,
                  outputs: outputs
                )
                @template_chef_server.merge(
                  resources: resources,
                  outputs: outputs
                )
              end
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
