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
                administrator_name = 'administrator_name'
                administrator_password = 'administrator_password'
                guid = 'guid'
                vpc_guid = 'vpc_guid'
                vpc_cidr = 'vpc_cidr'
                kms_key = 'kms_key'
                private_hosted_zone_id = 'private_hosted_zone_id'
                public_hosted_zone_id = 'public_hosted_zone_id'
                bucket = 'bucket'
                name = 'name'
                target = 'target'
                os = 'os'
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
                ).as_stubbed_const transfer_nested_constants: true
                allow(template_security_group_class).to receive(:new).with(
                  os: os,
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
                  hosted_zone_name: hosted_zone_name,
                  os: os,
                  wait_condition_handle: @wait_condition_handle_id
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
                allow(dsl_instance).to receive(
                  :os
                ) { os }
                template_block_devices = instance_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::BlockDevices'
                )
                @block_devices = 'block_devices'
                allow(template_block_devices).to receive(
                  :merge
                ) do |properties:|
                  properties[:block_devices] = @block_devices
                end
                dsl_block_devices = 'dsl_block_devices'
                allow(dsl_instance).to receive(:block_device).with(
                  no_args
                ) { dsl_block_devices }
                template_block_devices_class = class_double(
                  'Formatron::CloudFormation::Template' \
                  '::VPC::Subnet::Instance::BlockDevices'
                ).as_stubbed_const
                allow(template_block_devices_class).to receive(:new).with(
                  block_devices: dsl_block_devices
                ) { template_block_devices }
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
                  administrator_name: administrator_name,
                  administrator_password: administrator_password,
                  subnet: subnet_id,
                  name: "#{sub_domain}.#{hosted_zone_name}",
                  wait_condition_handle: @wait_condition_handle_id,
                  security_group: @security_group_id,
                  logical_id: @instance_id,
                  source_dest_check: source_dest_check,
                  os: os
                ) do
                  {
                    instance: @instance,
                    Properties: {}
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
                  hosted_zone_id: { Ref: private_hosted_zone_id },
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

                @public_alias_record_set_ids = []
                @public_alias_record_sets = []
                public_aliases = []
                allow(dsl_instance).to receive(
                  :public_alias
                ) { public_aliases }
                (0..2).each do |index|
                  public_aliases[index] = "public_alias#{index}"
                  @public_alias_record_set_ids[index] =
                    "publicAliasRecordSet#{index}#{guid}"
                  @public_alias_record_sets[index] =
                    "public_alias_record_set#{index}"
                  allow(route53).to receive(:record_set).with(
                    hosted_zone_id: public_hosted_zone_id,
                    sub_domain: public_aliases[index],
                    hosted_zone_name: hosted_zone_name,
                    instance: @instance_id,
                    attribute: 'PublicIp'
                  ) { @public_alias_record_sets[index] }
                end

                @private_alias_record_set_ids = []
                @private_alias_record_sets = []
                private_aliases = []
                allow(dsl_instance).to receive(
                  :private_alias
                ) { private_aliases }
                (0..2).each do |index|
                  private_aliases[index] = "private_alias#{index}"
                  @private_alias_record_set_ids[index] =
                    "privateAliasRecordSet#{index}#{guid}"
                  @private_alias_record_sets[index] =
                    "private_alias_record_set#{index}"
                  allow(route53).to receive(:record_set).with(
                    hosted_zone_id: { Ref: private_hosted_zone_id },
                    sub_domain: private_aliases[index],
                    hosted_zone_name: hosted_zone_name,
                    instance: @instance_id,
                    attribute: 'PrivateIp'
                  ) { @private_alias_record_sets[index] }
                end

                dsl_volumes = []
                @volume_attachment_ids = []
                @volume_attachments = []
                @volume_ids = []
                @volumes = []
                (0..9).each do |index|
                  @volume_attachment_ids[index] =
                    "volumeAttachment#{index}#{guid}"
                  volume_attachment = @volume_attachments[index] =
                    "volume_attachment#{index}"
                  volume_id = @volume_ids[index] = "volume#{index}#{guid}"
                  volume = @volumes[index] = "volume#{index}"
                  dsl_volume = dsl_volumes[index] = instance_double(
                    'Formatron::DSL::Formatron::VPC::Subnet::Instance::Volume'
                  )
                  device = "device#{index}"
                  allow(dsl_volume).to receive(:device) { device }
                  size = "size#{index}"
                  allow(dsl_volume).to receive(:size) { size }
                  type = "type#{index}"
                  allow(dsl_volume).to receive(:type) { type }
                  iops = "iops#{index}"
                  allow(dsl_volume).to receive(:iops) { iops }
                  allow(ec2).to receive(:volume_attachment).with(
                    device: device,
                    instance: "instance#{guid}",
                    volume: volume_id
                  ) { volume_attachment }
                  allow(ec2).to receive(:volume).with(
                    size: size,
                    type: type,
                    iops: iops,
                    availability_zone: availability_zone
                  ) { volume }
                end
                allow(dsl_instance).to receive(:volume).with(
                  no_args
                ) { dsl_volumes }

                template_instance = Instance.new(
                  instance: dsl_instance,
                  key_pair: key_pair,
                  administrator_name: administrator_name,
                  administrator_password: administrator_password,
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

              it 'should add the volumes' do
                @volumes.each_index do |index|
                  expect(@resources).to include(
                    @volume_ids[index] => @volumes[index]
                  )
                end
              end

              it 'should add the volume attachments' do
                @volume_attachments.each_index do |index|
                  expect(@resources).to include(
                    @volume_attachment_ids[index] => @volume_attachments[index]
                  )
                end
              end

              it 'should add an instance with its block devices ' \
                 'and setup scripts' do
                expect(@resources).to include(
                  @instance_id => {
                    instance: @instance,
                    setup: @setup,
                    Properties: {
                      block_devices: @block_devices
                    }
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

              it 'should add private hosted zone record sets for the aliases' do
                @private_alias_record_set_ids.each_index do |index|
                  expect(@resources).to include(
                    @private_alias_record_set_ids[index] =>
                      @private_alias_record_sets[index]
                  )
                end
              end

              it 'should add a public hosted zone record set' do
                expect(@resources).to include(
                  @public_record_set_id => @public_record_set
                )
              end

              it 'should add public hosted zone record sets for the aliases' do
                @public_alias_record_set_ids.each_index do |index|
                  expect(@resources).to include(
                    @public_alias_record_set_ids[index] =>
                      @public_alias_record_sets[index]
                  )
                end
              end
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
