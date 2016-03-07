require_relative 'instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation Bastion resources
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
              @bastion = bastion
              _set_os
              _add_open_ports
              @instance = Instance.new(
                instance: bastion,
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
            # rubocop:enable Metrics/ParameterLists
            # rubocop:enable Metrics/MethodLength

            def _set_os
              @bastion.os(
                'ubuntu'
              )
            end

            def _add_open_ports
              @bastion.security_group do |security_group|
                security_group.open_tcp_port 22
              end
            end

            def merge(resources:, outputs:)
              @instance.merge resources: resources, outputs: outputs
            end

            private(
              :_set_os,
              :_add_open_ports
            )
          end
        end
      end
    end
  end
end
