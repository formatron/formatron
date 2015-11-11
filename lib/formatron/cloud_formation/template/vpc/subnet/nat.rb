require_relative 'instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation Chef Server resources
          class NAT
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
              public_hosted_zone_id:,
              bucket:,
              name:,
              target:
            )
              @nat = nat
              @vpc_cidr = vpc_cidr
              _add_setup_script
              @instance = Instance.new(
                instance: nat,
                key_pair: key_pair,
                availability_zone: availability_zone,
                subnet_guid: subnet_guid,
                hosted_zone_name: hosted_zone_name,
                vpc_guid: vpc_guid,
                vpc_cidr: @vpc_cidr,
                kms_key: kms_key,
                private_hosted_zone_id: private_hosted_zone_id,
                public_hosted_zone_id: public_hosted_zone_id,
                bucket: bucket,
                name: name,
                target: target
              )
            end
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/MethodLength

            # rubocop:disable Metrics/MethodLength
            def _add_setup_script
              @nat.setup do |setup|
                scripts = setup.script
                scripts.unshift Scripts.nat cidr: @vpc_cidr
              end
            end
            # rubocop:enable Metrics/MethodLength

            def merge(resources:, outputs:)
              @instance.merge resources: resources, outputs: outputs
            end

            private(
              :_add_setup_script
            )
          end
        end
      end
    end
  end
end
