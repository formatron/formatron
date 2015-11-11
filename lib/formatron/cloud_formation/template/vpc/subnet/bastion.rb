class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation bastion resources
          class Bastion
            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/ParameterLists
            def initialize(
              bastion:,
              key_pair:,
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
              @key_pair = key_pair
              @availability_zone = availability_zone
              @subnet_guid = subnet_guid
              @hosted_zone_name = hosted_zone_name
              @bastion = bastion
              @vpc_guid = vpc_guid
              @vpc_cidr = vpc_cidr
              @kms_key = kms_key
              @private_hosted_zone_id = private_hosted_zone_id
              @public_hosted_zone_id = public_hosted_zone_id
              @bucket = bucket
              @name = name
              @target = target
            end
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/MethodLength

            def merge(resources:, outputs:)
              @resources = resources
              @outputs = outputs
            end
          end
        end
      end
    end
  end
end
