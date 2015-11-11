require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/bastion'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing for tests
        class Subnet
          describe ChefServer do
            before :each do
              bucket = 'bucket'
              name = 'name'
              target = 'target'
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              dsl_bastion = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet::Instance'
              )
              @dsl_security_group = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::SecurityGroup'
              )
              allow(@dsl_security_group).to receive(:open_tcp_port)
              allow(dsl_bastion).to receive(
                :security_group
              ) do |&block|
                block.call @dsl_security_group
              end
              @template_instance = instance_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              )
              template_instance_class = class_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              ).as_stubbed_const
              allow(template_instance_class).to receive(:new).with(
                instance: dsl_bastion,
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
              ) { @template_instance }
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

            it 'should open port for SSH' do
              expect(@dsl_security_group).to have_received(
                :open_tcp_port
              ).with 22
            end

            describe '#merge' do
              before :each do
                @resources = {}
                @outputs = {}
                allow(@template_instance).to receive :merge
                @template_bastion.merge(
                  resources: @resources,
                  outputs: @outputs
                )
              end

              it 'should pass through to the Instance merge method' do
                expect(@template_instance).to have_received(:merge).with(
                  resources: @resources,
                  outputs: @outputs
                )
              end
            end
          end
        end
      end
    end
  end
end
