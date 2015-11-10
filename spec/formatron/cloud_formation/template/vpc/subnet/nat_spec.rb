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
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              formatronfile_nat = instance_double(
                'Formatron::Formatronfile::VPC::Subnet::NAT'
              )
              @template_nat = NAT.new(
                nat: formatronfile_nat,
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
