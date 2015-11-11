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
              @guid = 'guid'
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              username = 'username'
              first_name = 'first_name'
              last_name = 'last_name'
              email = 'email'
              password = 'password'
              organization_short_name = 'organization_short_name'
              organization_full_name = 'organization_full_name'
              version = 'version'
              cookbooks_bucket = 'cookbooks_bucket'
              chef_server_cert_class = class_double(
                'Formatron::S3::ChefServerCert'
              ).as_stubbed_const
              allow(chef_server_cert_class).to receive(
                :cert_key
              ).with(
                name: name,
                target: target,
                guid: @guid
              ) { @ssl_cert_key }
              allow(chef_server_cert_class).to receive(
                :key_key
              ).with(
                name: name,
                target: target,
                guid: @guid
              ) { @ssl_key_key }
              chef_server_keys_class = class_double(
                'Formatron::S3::ChefServerKeys'
              ).as_stubbed_const
              allow(chef_server_keys_class).to receive(
                :user_pem_key
              ).with(
                name: name,
                target: target,
                guid: @guid
              ) { @user_pem_key }
              allow(chef_server_keys_class).to receive(
                :organization_pem_key
              ).with(
                name: name,
                target: target,
                guid: @guid
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
              dsl_setup = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Setup'
              )
              @dsl_region_variable = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Setup::Variable'
              )
              allow(@dsl_region_variable).to receive(:value)
              @dsl_access_key_id_variable = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Setup::Variable'
              )
              allow(@dsl_access_key_id_variable).to receive(:value)
              @dsl_secret_access_key_variable = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Setup::Variable'
              )
              allow(@dsl_secret_access_key_variable).to receive(:value)
              dsl_variables = {
                'REGION' => @dsl_region_variable,
                'ACCESS_KEY_ID' => @dsl_access_key_id_variable,
                'SECRET_ACCESS_KEY' => @dsl_secret_access_key_variable
              }
              allow(dsl_setup).to receive(:variable) do |key, &block|
                block.call dsl_variables[key]
              end
              @existing_script = 'existing_script'
              @chef_server_script = 'chef_server_script'
              scripts_class = class_double(
                'Formatron::CloudFormation::Scripts'
              ).as_stubbed_const
              allow(scripts_class).to receive(:chef_server).with(
                username: username,
                first_name: first_name,
                last_name: last_name,
                email: email,
                password: password,
                organization_short_name: organization_short_name,
                organization_full_name: organization_full_name,
                bucket: @bucket,
                user_pem_key: @user_pem_key,
                organization_pem_key: @organization_pem_key,
                kms_key: kms_key,
                chef_server_version: version,
                ssl_cert_key: @ssl_cert_key,
                ssl_key_key: @ssl_key_key,
                cookbooks_bucket: cookbooks_bucket
              ) { @chef_server_script }
              @scripts = [@existing_script]
              allow(dsl_setup).to receive(:script).with(
                no_args
              ) { @scripts }
              allow(dsl_chef_server).to receive(:setup) do |&block|
                block.call dsl_setup
              end
              @dsl_security_group = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::SecurityGroup'
              )
              allow(@dsl_security_group).to receive(:open_tcp_port)
              allow(dsl_chef_server).to receive(
                :security_group
              ) do |&block|
                block.call @dsl_security_group
              end
              allow(dsl_chef_server).to receive(:guid).with(
                no_args
              ) { @guid }
              allow(dsl_chef_server).to receive(:username) { username }
              allow(dsl_chef_server).to receive(:password) { password }
              allow(dsl_chef_server).to receive(:first_name) { first_name }
              allow(dsl_chef_server).to receive(:last_name) { last_name }
              allow(dsl_chef_server).to receive(:email) { email }
              allow(dsl_chef_server).to receive(
                :version
              ) { version }
              allow(dsl_chef_server).to receive(
                :cookbooks_bucket
              ) { cookbooks_bucket }
              organization = instance_double(
                'Formatron::DSL::VPC::Subnet::ChefServer::Organization'
              )
              allow(dsl_chef_server).to receive(:organization) { organization }
              allow(organization).to receive(
                :short_name
              ) { organization_short_name }
              allow(organization).to receive(
                :full_name
              ) { organization_full_name }
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

            it 'should open ports for Chef Server' do
              expect(@dsl_security_group).to have_received(
                :open_tcp_port
              ).with 80
              expect(@dsl_security_group).to have_received(
                :open_tcp_port
              ).with 443
            end

            it 'should add variables for setup scripts' do
              expect(@dsl_region_variable).to have_received(
                :value
              ).with(
                Ref: 'AWS::Region'
              )
              expect(@dsl_access_key_id_variable).to have_received(
                :value
              ).with(
                Ref: "accessKey#{@guid}"
              )
              expect(@dsl_secret_access_key_variable).to have_received(
                :value
              ).with(
                'Fn::GetAtt' => ["accessKey#{@guid}", 'SecretAccessKey']
              )
            end

            it 'should prepend the Chef Server setup script to the scripts' do
              expect(@scripts).to eql [
                @chef_server_script,
                @existing_script
              ]
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
