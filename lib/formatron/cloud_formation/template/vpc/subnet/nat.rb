class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation NAT resources
          class NAT
            ROUTE_TABLE_PREFIX = 'routeTable'

            # rubocop:disable Metrics/MethodLength
            # rubocop:disable Metrics/ParameterLists
            def initialize(
              nat:,
              key_pair:,
              availability_zone:,
              subnet_guid:,
              hosted_zone_name:,
              vpc_guid:,
              vpc_cidr:,
              kms_key:,
              private_hosted_zone_id:,
              public_hosted_zone_id:
            )
              @key_pair = key_pair
              @availability_zone = availability_zone
              @subnet_guid = subnet_guid
              @hosted_zone_name = hosted_zone_name
              @nat = nat
              @vpc_guid = vpc_guid
              @vpc_cidr = vpc_cidr
              @kms_key = kms_key
              @private_hosted_zone_id = private_hosted_zone_id
              @public_hosted_zone_id = public_hosted_zone_id
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
