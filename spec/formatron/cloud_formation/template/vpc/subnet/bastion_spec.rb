require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/bastion'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing tests
        class Subnet
          describe Bastion do
            before :each do
              formatronfile_bastion = instance_double(
                'Formatron::Formatronfile::VPC::Subnet::Bastion'
              )
              @template_bastion = Bastion.new bastion: formatronfile_bastion
            end

            describe '#merge' do
              it 'should add the resources' do
                resources = {}
                outputs = {}
                @template_bastion.merge resources: resources, outputs: outputs
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
