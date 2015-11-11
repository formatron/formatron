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
                guid = 'guid'
                vpc_guid = 'vpc_guid'
                vpc_cidr = 'vpc_cidr'
                kms_key = 'kms_key'
                private_hosted_zone_id = 'private_hosted_zone_id'
                public_hosted_zone_id = 'public_hosted_zone_id'
                bucket = 'bucket'
                name = 'name'
                target = 'target'
                dsl_instance = instance_double(
                  'Formatron::DSL::Formatron::VPC::Subnet::Instance'
                )
                allow(dsl_instance).to receive(:guid) { guid }
                iam = class_double(
                  'Formatron::CloudFormation::Resources::IAM'
                ).as_stubbed_const
                ec2 = class_double(
                  'Formatron::CloudFormation::Resources::EC2'
                ).as_stubbed_const
                cloud_formation = class_double(
                  'Formatron::CloudFormation::Resources::CloudFormation'
                ).as_stubbed_const
                route53 = class_double(
                  'Formatron::CloudFormation::Resources::Route53'
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

                dsl_policy = instance_double(
                  'Formatron::DSL::Formatron::VPC::Subnet::Instance::Policy'
                )
                allow(dsl_instance).to receive(
                  :policy
                ) { dsl_policy }

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
                  policy: dsl_policy,
                  instance_guid: guid,
                  kms_key: kms_key,
                  bucket: bucket,
                  name: name,
                  target: target
                ) { template_policy }
                allow(template_policy).to receive(:merge) do |resources:|
                  resources[@policy_id] = @policy
                end

                dsl_security_group = instance_double(
                  'Formatron::DSL::Formatron::VPC::Subnet' \
                  '::Instance::SecurityGroup'
                )
                allow(dsl_instance).to receive(
                  :security_group
                ) { dsl_security_group }

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
                stub_const(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::SecurityGroup' \
                  '::SECURITY_GROUP_PREFIX',
                  'securityGroup'
                )
                allow(template_security_group_class).to receive(:new).with(
                  security_group: dsl_security_group,
                  instance_guid: guid,
                  vpc_guid: vpc_guid,
                  vpc_cidr: vpc_cidr
                ) { template_security_group }
                allow(template_security_group).to receive(
                  :merge
                ) do |resources:|
                  resources[@security_group_id] = @security_group
                end

                @wait_condition_handle_id = "waitConditionHandle#{guid}"
                @wait_condition_handle = 'wait_condition_handle'
                allow(cloud_formation).to receive(:wait_condition_handle).with(
                  no_args
                ) { @wait_condition_handle }

                template_setup = instance_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::Setup'
                )
                @setup = 'setup'
                allow(template_setup).to receive(:merge) do |instance:|
                  instance[:setup] = @setup
                end
                template_setup_class = class_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::Setup'
                ).as_stubbed_const
                dsl_setup = 'dsl_setup'
                sub_domain = 'sub_domain'
                hosted_zone_name = 'hosted_zone_name'
                allow(template_setup_class).to receive(:new).with(
                  setup: dsl_setup,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name
                ) { template_setup }
                allow(dsl_instance).to receive(
                  :setup
                ) { dsl_setup }
                allow(dsl_instance).to receive(
                  :sub_domain
                ) { sub_domain }
                source_dest_check = 'source_dest_check'
                allow(dsl_instance).to receive(
                  :source_dest_check
                ) { source_dest_check }
                instance_type = 'instance_type'
                allow(dsl_instance).to receive(
                  :instance_type
                ) { instance_type }
                availability_zone = 'availability_zone'
                subnet_guid = 'subnet_guid'
                subnet_id = "subnet#{subnet_guid}"
                @instance_id = "instance#{guid}"
                @instance = 'instance'
                allow(ec2).to receive(:instance).with(
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
                ) do
                  {
                    instance: @instance
                  }
                end

                @wait_condition_id = "waitCondition#{guid}"
                @wait_condition = 'wait_condition'
                allow(cloud_formation).to receive(:wait_condition).with(
                  wait_condition_handle: @wait_condition_handle_id,
                  instance: @instance_id
                ) { @wait_condition }

                @private_record_set_id = "privateRecordSet#{guid}"
                @private_record_set = 'private_record_set'
                allow(route53).to receive(:record_set).with(
                  hosted_zone_id: private_hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PrivateIp'
                ) { @private_record_set }

                @public_record_set_id = "publicRecordSet#{guid}"
                @public_record_set = 'public_record_set'
                allow(route53).to receive(:record_set).with(
                  hosted_zone_id: public_hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PublicIp'
                ) { @public_record_set }

                template_instance = Instance.new(
                  instance: dsl_instance,
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

              it 'should add a wait condition handle' do
                expect(@resources).to include(
                  @wait_condition_handle_id => @wait_condition_handle
                )
              end

              it 'should add an instance with its setup scripts' do
                expect(@resources).to include(
                  @instance_id => {
                    instance: @instance,
                    setup: @setup
                  }
                )
                expect(@outputs).to include(
                  @instance_id => {
                    Value: { Ref: @instance_id }
                  }
                )
              end

              it 'should add a wait condition' do
                expect(@resources).to include(
                  @wait_condition_id => @wait_condition
                )
              end

              it 'should add a private hosted zone record set' do
                expect(@resources).to include(
                  @private_record_set_id => @private_record_set
                )
              end

              it 'should add a public hosted zone record set' do
                expect(@resources).to include(
                  @public_record_set_id => @public_record_set
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
