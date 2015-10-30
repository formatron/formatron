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
            @region = 'region'
            @bucket = 'bucket'
            @target = 'target'
            @name = 'name'
            @vpc = 'vpc'
            @bootstrap = instance_double(
              'Formatron::Configuration::Formatronfile::Bootstrap'
            )
            allow(@bootstrap).to receive(:vpc) { @vpc }

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
          end

          describe '#json' do
            it 'should return the JSON CloudFormation template' do
              expect(
                BootstrapTemplate.json(
                  region: @region,
                  bucket: @bucket,
                  target: @target,
                  name: @name,
                  bootstrap: @bootstrap
                )
              ).to eql <<-EOH.gsub(/^ {16}/, '')
                {
                  "description": "bootstrap-#{@name}-#{@target}",
                  "vpc": "#{@vpc}"
                }
              EOH
            end
          end
        end
      end
    end
  end
end
