require 'formatron/cloud_formation/resources/iam'
require 'formatron/cloud_formation/resources/ec2'
require 'formatron/cloud_formation/resources/cloud_formation'
require 'formatron/cloud_formation/resources/route53'
require_relative 'instance/policy'
require_relative 'instance/security_group'
require_relative 'instance/setup'
require_relative 'instance/block_devices'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation instance resources
          # rubocop:disable Metrics/ClassLength
          class Instance
            INSTANCE_PREFIX = 'instance'
            ROLE_PREFIX = 'role'
            INSTANCE_PROFILE_PREFIX = 'instanceProfile'
            WAIT_CONDITION_HANDLE_PREFIX = 'waitConditionHandle'
            WAIT_CONDITION_PREFIX = 'waitCondition'
            PRIVATE_RECORD_SET_PREFIX = 'privateRecordSet'
            PUBLIC_RECORD_SET_PREFIX = 'publicRecordSet'
            PUBLIC_ALIAS_RECORD_SET_PREFIX = 'publicAliasRecordSet'
            PRIVATE_ALIAS_RECORD_SET_PREFIX = 'privateAliasRecordSet'
            VOLUME_PREFIX = 'volume'
            VOLUME_ATTACHMENT_PREFIX = 'volumeAttachment'

            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/AbcSize
            # rubocop:disable Metrics/ParameterLists
            def initialize(
              instance:,
              key_pair:,
              administrator_name:,
              administrator_password:,
              availability_zone:,
              subnet_guid:,
              hosted_zone_name:,
              vpc_guid:,
              vpc_cidr:,
              kms_key:,
              private_hosted_zone_id:,
              public_hosted_zone_id:,
              bucket:,
              name:,
              target:
            )
              @instance = instance
              @guid = @instance.guid
              @setup = @instance.setup
              @block_devices = @instance.block_device
              @instance_id = "#{INSTANCE_PREFIX}#{@guid}"
              @role_id = "#{ROLE_PREFIX}#{@guid}"
              @instance_profile_id = "#{INSTANCE_PROFILE_PREFIX}#{@guid}"
              @wait_condition_handle_id =
                "#{WAIT_CONDITION_HANDLE_PREFIX}#{@guid}"
              @wait_condition_id =
                "#{WAIT_CONDITION_PREFIX}#{@guid}"
              @policy = @instance.policy
              @security_group = @instance.security_group
              @security_group_id =
                "#{SecurityGroup::SECURITY_GROUP_PREFIX}#{@guid}"
              @availability_zone = availability_zone
              @instance_type = @instance.instance_type || 't2.micro'
              @os = @instance.os || 'ubuntu'
              @ami = @instance.ami
              @key_pair = key_pair
              @administrator_name = administrator_name
              @administrator_password = administrator_password
              @subnet_guid = subnet_guid
              @subnet_id = "#{Subnet::SUBNET_PREFIX}#{@subnet_guid}"
              @sub_domain = @instance.sub_domain
              @hosted_zone_name = hosted_zone_name
              @source_dest_check = @instance.source_dest_check
              @source_dest_check =
                @source_dest_check.nil? ? true : @source_dest_check
              @vpc_guid = vpc_guid
              @vpc_cidr = vpc_cidr
              @kms_key = kms_key
              @private_hosted_zone_id = private_hosted_zone_id
              @public_hosted_zone_id = public_hosted_zone_id
              @private_record_set_id =
                "#{PRIVATE_RECORD_SET_PREFIX}#{@guid}"
              @public_record_set_id =
                "#{PUBLIC_RECORD_SET_PREFIX}#{@guid}"
              @public_aliases = @instance.public_alias
              @private_aliases = @instance.private_alias
              @volumes = @instance.volume
              @bucket = bucket
              @name = name
              @target = target
            end
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/AbcSize
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/AbcSize
            def merge(resources:, outputs:)
              @outputs = outputs
              resources[@role_id] = Resources::IAM.role
              resources[@instance_profile_id] = Resources::IAM.instance_profile(
                role: @role_id
              )
              policy = Policy.new(
                policy: @policy,
                instance_guid: @guid,
                kms_key: @kms_key,
                bucket: @bucket,
                name: @name,
                target: @target
              )
              policy.merge resources: resources
              security_group = SecurityGroup.new(
                os: @os,
                security_group: @security_group,
                instance_guid: @guid,
                vpc_guid: @vpc_guid,
                vpc_cidr: @vpc_cidr
              )
              security_group.merge resources: resources
              resources[@wait_condition_handle_id] =
                Resources::CloudFormation.wait_condition_handle
              instance = Resources::EC2.instance(
                instance_profile: @instance_profile_id,
                availability_zone: @availability_zone,
                instance_type: @instance_type,
                key_name: @key_pair,
                administrator_name: @administrator_name,
                administrator_password: @administrator_password,
                subnet: @subnet_id,
                name: "#{@sub_domain}.#{@hosted_zone_name}",
                wait_condition_handle: @wait_condition_handle_id,
                security_group: @security_group_id,
                logical_id: @instance_id,
                source_dest_check: @source_dest_check,
                os: @os,
                ami: @ami
              )
              setup = Setup.new(
                setup: @setup,
                sub_domain: @sub_domain,
                hosted_zone_name: @hosted_zone_name,
                os: @os,
                wait_condition_handle: @wait_condition_handle_id
              )
              setup.merge instance: instance
              block_devices = BlockDevices.new(
                block_devices: @block_devices
              )
              block_devices.merge properties: instance[:Properties]
              resources[@instance_id] = instance
              outputs[@instance_id] = Template.output(
                Template.ref(@instance_id)
              )
              resources[@wait_condition_id] =
                Resources::CloudFormation.wait_condition(
                  wait_condition_handle: @wait_condition_handle_id,
                  instance: @instance_id
                )
              resources[@private_record_set_id] =
                Resources::Route53.record_set(
                  hosted_zone_id: Template.ref(@private_hosted_zone_id),
                  sub_domain: @sub_domain,
                  hosted_zone_name: @hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PrivateIp'
                )
              resources[@public_record_set_id] =
                Resources::Route53.record_set(
                  hosted_zone_id: @public_hosted_zone_id,
                  sub_domain: @sub_domain,
                  hosted_zone_name: @hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PublicIp'
                ) unless @public_hosted_zone_id.nil?
              _add_public_aliases resources unless @public_hosted_zone_id.nil?
              _add_private_aliases resources
              _add_volumes resources
            end
            # rubocop:enable Metrics/AbcSize
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_public_aliases(resources)
              @public_aliases.each_index do |index|
                sub_domain = @public_aliases[index]
                logical_id = "#{PUBLIC_ALIAS_RECORD_SET_PREFIX}#{index}#{@guid}"
                resources[logical_id] = Resources::Route53.record_set(
                  hosted_zone_id: @public_hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: @hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PublicIp'
                )
              end
            end
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_private_aliases(resources)
              @private_aliases.each_index do |index|
                sub_domain = @private_aliases[index]
                logical_id =
                  "#{PRIVATE_ALIAS_RECORD_SET_PREFIX}#{index}#{@guid}"
                resources[logical_id] = Resources::Route53.record_set(
                  hosted_zone_id: Template.ref(@private_hosted_zone_id),
                  sub_domain: sub_domain,
                  hosted_zone_name: @hosted_zone_name,
                  instance: @instance_id,
                  attribute: 'PrivateIp'
                )
              end
            end
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_volumes(resources)
              @volumes.each_index do |index|
                volume = @volumes[index]
                volume_id = "#{VOLUME_PREFIX}#{index}#{@guid}"
                volume_attachment_id =
                  "#{VOLUME_ATTACHMENT_PREFIX}#{index}#{@guid}"
                resources[volume_id] = Resources::EC2.volume(
                  availability_zone: @availability_zone,
                  size: volume.size,
                  type: volume.type,
                  iops: volume.iops
                )
                resources[volume_attachment_id] =
                  Resources::EC2.volume_attachment(
                    device: volume.device,
                    instance: "#{INSTANCE_PREFIX}#{@guid}",
                    volume: volume_id
                  )
              end
            end
            # rubocop:enable Metrics/MethodLength

            private(
              :_add_public_aliases,
              :_add_private_aliases,
              :_add_volumes
            )
          end
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
