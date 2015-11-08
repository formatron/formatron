require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/nat'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing tests
        class Subnet
          describe NAT do
            before :each do
              formatronfile_nat = instance_double(
                'Formatron::Formatronfile::VPC::Subnet::NAT'
              )
              @template_nat = NAT.new nat: formatronfile_nat
            end

            describe '#merge' do
              it 'should add the resources' do
                resources = {}
                outputs = {}
                @template_nat.merge resources: resources, outputs: outputs
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
