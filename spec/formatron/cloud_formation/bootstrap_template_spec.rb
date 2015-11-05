require 'spec_helper'
require 'formatron' \
        '/cloud_formation/bootstrap_template'

class Formatron
  # namespacing for tests
  # rubocop:disable Metrics/ModuleLength
  module CloudFormation
    describe BootstrapTemplate do
      before :each do
        @hosted_zone_id = 'hosted_zone_id'
        @hosted_zone_name = 'hosted_zone_name'
        @bucket = 'bucket'
        @target = 'target'
        @name = 'name'
        @vpc = 'vpc'
        @nat = 'nat'
        @bastion = 'bastion'
        @chef_server = 'chef_server'
        @config_key = 'config_key'
        @user_pem_key = 'user_pem_key'
        @organization_pem_key = 'organization_pem_key'
        @ssl_cert_key = 'ssl_cert_key'
        @ssl_key_key = 'ssl_key_key'
        @region_map = 'region_map'
        @bootstrap = instance_double(
          'Formatron::Formatronfile::Bootstrap'
        )
        allow(@bootstrap).to receive(:vpc) { @vpc }
        allow(@bootstrap).to receive(:nat) { @nat }
        allow(@bootstrap).to receive(:bastion) { @bastion }
        allow(@bootstrap).to receive(:chef_server) { @chef_server }

        template_module = class_double(
          'Formatron' \
          '::CloudFormation::Template'
        ).as_stubbed_const
        allow(template_module).to receive(:create) do |description|
          {
            description: description
          }
        end
        allow(template_module).to receive(
          :add_region_map
        ) do |template:|
          template[:region_map] = @region_map
        end
        allow(template_module).to receive(
          :add_vpc
        ) do |template:, vpc:|
          template[:vpc] = vpc
        end
        allow(template_module).to receive(
          :add_private_hosted_zone
        ) do |template:, hosted_zone_name:|
          template[:private_hosted_zone] = hosted_zone_name
        end
        # rubocop:disable Metrics/ParameterLists
        allow(template_module).to receive(
          :add_nat
        # rubocop:disable Metrics/LineLength
        ) do |template:, hosted_zone_id:, hosted_zone_name:, bootstrap:, bucket:, config_key:|
          # rubocop:enable Metrics/LineLength
          template[:nat] = {
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap.nat,
            bucket: bucket,
            config_key: config_key
          }
        end
        # rubocop:enable Metrics/ParameterLists
        # rubocop:disable Metrics/ParameterLists
        allow(template_module).to receive(
          :add_bastion
        # rubocop:disable Metrics/LineLength
        ) do |template:, hosted_zone_id:, hosted_zone_name:, bootstrap:, bucket:, config_key:|
          # rubocop:enable Metrics/LineLength
          template[:bastion] = {
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap.bastion,
            bucket: bucket,
            config_key: config_key
          }
        end
        # rubocop:enable Metrics/ParameterLists
        # rubocop:disable Metrics/ParameterLists
        allow(template_module).to receive(
          :add_chef_server
        # rubocop:disable Metrics/LineLength
        ) do |template:, hosted_zone_id:, hosted_zone_name:, bootstrap:, bucket:, config_key:, user_pem_key:, organization_pem_key:, ssl_cert_key:, ssl_key_key:|
          # rubocop:enable Metrics/LineLength
          template[:chef_server] = {
            hosted_zone_id: hosted_zone_id,
            hosted_zone_name: hosted_zone_name,
            bootstrap: bootstrap.chef_server,
            bucket: bucket,
            config_key: config_key,
            user_pem_key: user_pem_key,
            organization_pem_key: organization_pem_key,
            ssl_cert_key: ssl_cert_key,
            ssl_key_key: ssl_key_key
          }
        end
        # rubocop:enable Metrics/ParameterLists
      end

      describe '#json' do
        it 'should return the JSON CloudFormation template' do
          expect(
            BootstrapTemplate.json(
              hosted_zone_id: @hosted_zone_id,
              hosted_zone_name: @hosted_zone_name,
              bucket: @bucket,
              config_key: @config_key,
              user_pem_key: @user_pem_key,
              organization_pem_key: @organization_pem_key,
              ssl_cert_key: @ssl_cert_key,
              ssl_key_key: @ssl_key_key,
              bootstrap: @bootstrap
            )
          ).to eql <<-EOH.gsub(/^ {12}/, '')
            {
              "description": "formatron-bootstrap",
              "region_map": "#{@region_map}",
              "private_hosted_zone": "#{@hosted_zone_name}",
              "vpc": "#{@vpc}",
              "nat": {
                "hosted_zone_id": "#{@hosted_zone_id}",
                "hosted_zone_name": "#{@hosted_zone_name}",
                "bootstrap": "#{@nat}",
                "bucket": "#{@bucket}",
                "config_key": "#{@config_key}"
              },
              "bastion": {
                "hosted_zone_id": "#{@hosted_zone_id}",
                "hosted_zone_name": "#{@hosted_zone_name}",
                "bootstrap": "#{@bastion}",
                "bucket": "#{@bucket}",
                "config_key": "#{@config_key}"
              },
              "chef_server": {
                "hosted_zone_id": "#{@hosted_zone_id}",
                "hosted_zone_name": "#{@hosted_zone_name}",
                "bootstrap": "#{@chef_server}",
                "bucket": "#{@bucket}",
                "config_key": "#{@config_key}",
                "user_pem_key": "#{@user_pem_key}",
                "organization_pem_key": "#{@organization_pem_key}",
                "ssl_cert_key": "#{@ssl_cert_key}",
                "ssl_key_key": "#{@ssl_key_key}"
              }
            }
          EOH
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
