require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/chef_server'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing tests
        class Subnet
          describe ChefServer do
            before :each do
              formatronfile_chef_server = instance_double(
                'Formatron::Formatronfile::VPC::Subnet::ChefServer'
              )
              @template_chef_server = ChefServer.new(
                chef_server: formatronfile_chef_server
              )
            end

            describe '#merge' do
              it 'should add the resources' do
                resources = {}
                outputs = {}
                @template_chef_server.merge(
                  resources: resources, outputs: outputs
                )
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
