require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # namespacing tests
        class Subnet
          describe Instance do
            describe '#merge' do
              before :each do
                formatronfile_instance = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet::Instance'
                )
                guid = 'guid'
                allow(formatronfile_instance).to receive(:guid) { guid }
                iam = class_double(
                  'Formatron::CloudFormation::Resources::IAM'
                ).as_stubbed_const

                @role_id = "role#{guid}"
                @role = 'role'
                allow(iam).to receive(:role).with(
                  no_args
                ) { @role }

                formatronfile_policy = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet::Instance::Policy'
                )
                allow(formatronfile_instance).to receive(
                  :policy
                ) { formatronfile_policy }

                @policy_id = "policy#{guid}"
                @policy = 'policy'
                template_policy = instance_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::Policy'
                )
                template_policy_class = class_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::Policy'
                ).as_stubbed_const
                allow(template_policy_class).to receive(:new).with(
                  policy: formatronfile_policy
                ) { template_policy }
                allow(template_policy).to receive(:merge) do |resources:|
                  resources[@policy_id] = @policy
                end

                formatronfile_security_group = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet' \
                  '::Instance::SecurityGroup'
                )
                allow(formatronfile_instance).to receive(
                  :security_group
                ) { formatronfile_security_group }

                @security_group_id = "securityGroup#{guid}"
                @security_group = 'security_group'
                template_security_group = instance_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::SecurityGroup'
                )
                template_security_group_class = class_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::SecurityGroup'
                ).as_stubbed_const
                allow(template_security_group_class).to receive(:new).with(
                  security_group: formatronfile_security_group
                ) { template_security_group }
                allow(template_security_group).to receive(
                  :merge
                ) do |resources:|
                  resources[@security_group_id] = @security_group
                end

                template_instance = Instance.new(
                  instance: formatronfile_instance
                )
                @resources = {}
                @outputs = {}
                template_instance.merge resources: @resources, outputs: @outputs
              end

              it 'should add a role' do
                expect(@resources).to include(
                  @role_id => @role
                )
              end

              it 'should add a policy' do
                expect(@resources).to include(
                  @policy_id => @policy
                )
              end

              it 'should add a security group' do
                expect(@resources).to include(
                  @security_group_id => @security_group
                )
              end
            end
          end
        end
      end
    end
  end
end
