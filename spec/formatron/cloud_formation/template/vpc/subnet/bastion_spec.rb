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
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              bucket = 'bucket'
              name = 'name'
              target = 'target'
              dsl_bastion = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet::Bastion'
              )
              @template_bastion = Bastion.new(
                bastion: dsl_bastion,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: vpc_guid,
                vpc_cidr: vpc_cidr,
                kms_key: kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: bucket,
                name: name,
                target: target
              )
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
