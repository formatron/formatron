require 'spec_helper'
require 'formatron/configuration/formatronfile' \
        '/cloud_formation/bootstrap_template'

class Formatron
  class Configuration
    # namespacing for tests
    module CloudFormation
      describe BootstrapTemplate do
        region = 'region'
        bucket = 'bucket'
        target = 'target'
        name = 'name'

        before :each do
          @bootstrap = instance_double(
            'Formatron::Configuration::Formatronfile::Bootstrap'
          )
          allow(Template).to receive(:create) do |description|
            {
              description: description
            }
          end
        end

        describe '#json' do
          it 'should return the JSON CloudFormation template' do
            expect(
              BootstrapTemplate.json(
                region: region,
                bucket: bucket,
                target: target,
                name: name,
                bootstrap: @bootstrap
              )
            ).to eql <<-EOH.gsub(/^ {14}/, '')
              {
                "description": "bootstrap-#{name}-#{target}"
              }
            EOH
          end
        end
      end
    end
  end
end
