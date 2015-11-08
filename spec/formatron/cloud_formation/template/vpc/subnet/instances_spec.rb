require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing tests
        class Subnet
          describe Instance do
            before :each do
              formatronfile_instance = instance_double(
                'Formatron::Formatronfile::VPC::Subnet::Instance'
              )
              @template_instance = Instance.new instance: formatronfile_instance
            end

            describe '#merge' do
              it 'should add the resources' do
                resources = {}
                outputs = {}
                @template_instance.merge resources: resources, outputs: outputs
                expect(resources).to eql({})
                expect(outputs).to eql({})
              end
            end
          end
        end
      end
    end
  end
end
