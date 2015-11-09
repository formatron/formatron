require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # rubocop:disable Metrics/ClassLength
        class Subnet
          describe Instance do
            describe '#merge' do
              before :each do
                key_pair = 'key_pair'
                formatronfile_ec2 = instance_double(
                  'Formatron::Formatronfile::Global::EC2'
                )
                allow(formatronfile_ec2).to receive(
                  :key_pair
                ) { key_pair }
                formatronfile_global = instance_double(
                  'Formatron::Formatronfile::Global'
                )
                allow(formatronfile_global).to receive(
                  :ec2
                ) { formatronfile_ec2 }
                formatron = instance_double(
                  'Formatron'
                )
                formatronfile = instance_double(
                  'Formatron::Formatronfile'
                )
                allow(formatronfile).to receive(
                  :dsl_parent
                ) { formatron }
                allow(formatronfile).to receive(
                  :global
                ) { formatronfile_global }
                formatronfile_vpc = instance_double(
                  'Formatron::Formatronfile::VPC'
                )
                allow(formatronfile_vpc).to receive(
                  :dsl_parent
                ) { formatronfile }
                formatronfile_subnet = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet'
                )
                allow(formatronfile_subnet).to receive(
                  :dsl_parent
                ) { formatronfile_vpc }
                formatronfile_instance = instance_double(
                  'Formatron::Formatronfile::VPC::Subnet::Instance'
                )
                allow(formatronfile_instance).to receive(
                  :dsl_parent
                ) { formatronfile_subnet }
                guid = 'guid'
                allow(formatronfile_instance).to receive(:guid) { guid }
                iam = class_double(
                  'Formatron::CloudFormation::Resources::IAM'
                ).as_stubbed_const
                ec2 = class_double(
                  'Formatron::CloudFormation::Resources::EC2'
                ).as_stubbed_const

                @role_id = "role#{guid}"
                @role = 'role'
                allow(iam).to receive(:role).with(
                  no_args
                ) { @role }

                @instance_profile_id = "instanceProfile#{guid}"
                @instance_profile = 'instance_profile'
                allow(iam).to receive(:instance_profile).with(
                  role: @role_id
                ) { @instance_profile }

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

                @wait_condition_handle_id = "waitConditionHandle#{guid}"
                @wait_condition_handle = 'wait_condition_handle'

                setup = 'setup'
                allow(formatronfile_instance).to receive(:setup) { setup }
                sub_domain = 'sub_domain'
                allow(formatronfile_instance).to receive(
                  :sub_domain
                ) { sub_domain }
                source_dest_check = 'source_dest_check'
                allow(formatronfile_instance).to receive(
                  :source_dest_check
                ) { source_dest_check }
                instance_type = 'instance_type'
                allow(formatronfile_instance).to receive(
                  :instance_type
                ) { instance_type }
                availability_zone = 'availability_zone'
                allow(formatronfile_subnet).to receive(
                  :availability_zone
                ) { availability_zone }
                subnet_guid = 'subnet_guid'
                allow(formatronfile_subnet).to receive(
                  :guid
                ) { subnet_guid }
                subnet_id = "subnet#{subnet_guid}"
                hosted_zone_name = 'hosted_zone_name'
                allow(formatron).to receive(
                  :hosted_zone_name
                ) { hosted_zone_name }
                @instance_id = "instance#{guid}"
                @instance = 'instance'
                allow(ec2).to receive(:instance).with(
                  setup: setup,
                  instance_profile: @instance_profile_id,
                  availability_zone: availability_zone,
                  instance_type: instance_type,
                  key_name: key_pair,
                  subnet: subnet_id,
                  name: "#{sub_domain}.#{hosted_zone_name}",
                  wait_condition_handle: @wait_condition_handle_id,
                  security_group: @security_group_id,
                  logical_id: @instance_id,
                  source_dest_check: source_dest_check
                ) { @instance }

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

              it 'should add an instance profile' do
                expect(@resources).to include(
                  @instance_profile_id => @instance_profile
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

              it 'should add an instance' do
                expect(@resources).to include(
                  @instance_id => @instance
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
