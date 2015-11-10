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
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              dsl_chef_server = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet::ChefServer'
              )
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
                public_hosted_zone_id: public_hosted_zone_id
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
