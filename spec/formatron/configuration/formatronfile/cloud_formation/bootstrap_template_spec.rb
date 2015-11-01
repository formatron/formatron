require 'spec_helper'
require 'formatron/configuration/formatronfile' \
        '/cloud_formation/bootstrap_template'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      module CloudFormation
        describe BootstrapTemplate do
          before :each do
            @hosted_zone_id = 'hosted_zone_id'
            @hosted_zone_name = 'hosted_zone_name'
            @region = 'region'
            @bucket = 'bucket'
            @target = 'target'
            @name = 'name'
            @vpc = 'vpc'
            @nat = 'nat'
            @config_key = 'config_key'
            @bootstrap = instance_double(
              'Formatron::Configuration::Formatronfile::Bootstrap'
            )
            allow(@bootstrap).to receive(:vpc) { @vpc }
            allow(@bootstrap).to receive(:nat) { @nat }

            template_module = class_double(
              'Formatron::Configuration::Formatronfile' \
              '::CloudFormation::Template'
            ).as_stubbed_const
            allow(template_module).to receive(:create) do |description|
              {
                description: description
              }
            end
            allow(template_module).to receive(:add_vpc) do |template:, vpc:|
              template[:vpc] = vpc
            end
            allow(template_module).to receive(
              :add_nat
            ) do |template:, bootstrap:, bucket:, config_key:|
              template[:nat] = {
                bootstrap: bootstrap.nat,
                bucket: bucket,
                config_key: config_key
              }
            end
          end

          describe '#json' do
            it 'should return the JSON CloudFormation template' do
              expect(
                BootstrapTemplate.json(
                  hosted_zone_id: @hosted_zone_id,
                  hosted_zone_name: @hosted_zone_name,
                  bucket: @bucket,
                  config_key: @config_key,
                  bootstrap: @bootstrap
                )
              ).to eql <<-EOH.gsub(/^ {16}/, '')
                {
                  "description": "formatron-bootstrap",
                  "vpc": "#{@vpc}",
                  "nat": {
                    "bootstrap": "#{@nat}",
                    "bucket": "#{@bucket}",
                    "config_key": "#{@config_key}"
                  }
                }
              EOH
            end
          end
        end
      end
    end
  end
end
