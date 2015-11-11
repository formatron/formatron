require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/nat'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # rubocop:disable Metrics/ClassLength
        class Subnet
          describe NAT do
            before :each do
              @guid = 'guid'
              bucket = 'bucket'
              name = 'name'
              target = 'target'
              key_pair = 'key_pair'
              availability_zone = 'availability_zone'
              subnet_guid = 'subnet_guid'
              hosted_zone_name = 'hosted_zone_name'
              @vpc_guid = 'vpc_guid'
              vpc_cidr = 'vpc_cidr'
              kms_key = 'kms_key'
              private_hosted_zone_id = 'private_hosted_zone_id'
              public_hosted_zone_id = 'public_hosted_zone_id'
              @existing_script = 'existing_script'
              @nat_script = 'nat_script'
              scripts_class = class_double(
                'Formatron::CloudFormation::Scripts'
              ).as_stubbed_const
              allow(scripts_class).to receive(:nat).with(
                cidr: vpc_cidr
              ) { @nat_script }
              @scripts = [@existing_script]
              dsl_setup = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet' \
                '::Instance::Setup'
              )
              allow(dsl_setup).to receive(:script).with(
                no_args
              ) { @scripts }
              dsl_nat = instance_double(
                'Formatron::DSL::Formatron::VPC::Subnet::Instance'
              )
              allow(dsl_nat).to receive(:guid) { @guid }
              allow(dsl_nat).to receive(:setup) do |&block|
                block.call dsl_setup
              end
              @template_instance = instance_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              )
              template_instance_class = class_double(
                'Formatron::CloudFormation::Template::VPC' \
                '::Subnet::Instance'
              ).as_stubbed_const transfer_nested_constants: true
              allow(template_instance_class).to receive(:new).with(
                instance: dsl_nat,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: @vpc_guid,
                vpc_cidr: vpc_cidr,
                kms_key: kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: bucket,
                name: name,
                target: target
              ) { @template_instance }
              @template_nat = NAT.new(
                nat: dsl_nat,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: @vpc_guid,
                vpc_cidr: vpc_cidr,
                kms_key: kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: bucket,
                name: name,
                target: target
              )
            end

            it 'should prepend the NAT setup script to the scripts' do
              expect(@scripts).to eql [
                @nat_script,
                @existing_script
              ]
            end

            describe '#merge' do
              before :each do
                @resources = {}
                @outputs = {}
                ec2 = class_double(
                  'Formatron::CloudFormation::Resources::EC2'
                ).as_stubbed_const
                @route_table = 'route_table'
                @route_table_id = "routeTable#{@guid}"
                allow(ec2).to receive(:route_table).with(
                  vpc: "vpc#{@vpc_guid}"
                ) { @route_table }
                @route = 'route'
                @route_id = "route#{@guid}"
                allow(ec2).to receive(:route).with(
                  route_table: @route_table_id,
                  instance: "instance#{@guid}"
                ) { @route }
                allow(@template_instance).to receive :merge
                @template_nat.merge(
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

              it 'should add the NAT route table' do
                expect(@resources).to include(
                  @route_table_id => @route_table,
                  @route_id => @route
                )
              end
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
