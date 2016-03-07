require_relative 'instance'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation Chef Server resources
          class NAT
            ROUTE_TABLE_PREFIX = 'routeTable'
            ROUTE_PREFIX = 'route'

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
              guid = @nat.guid
              @vpc_cidr = vpc_cidr
              @vpc_id = "#{VPC::VPC_PREFIX}#{vpc_guid}"
              @instance_id = "#{Instance::INSTANCE_PREFIX}#{guid}"
              @route_table_id = "#{ROUTE_TABLE_PREFIX}#{guid}"
              @route_id = "#{ROUTE_PREFIX}#{guid}"
              _set_os
              _add_setup_script
              _set_source_dest_check
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

            def _set_os
              @nat.os(
                'ubuntu'
              )
            end

            def _add_setup_script
              @nat.setup do |setup|
                scripts = setup.script
                scripts.unshift Scripts.nat cidr: @vpc_cidr
              end
            end

            def _set_source_dest_check
              @nat.source_dest_check false
            end

            def merge(resources:, outputs:)
              _add_route_table resources
              @instance.merge resources: resources, outputs: outputs
            end

            def _add_route_table(resources)
              resources[@route_table_id] = Resources::EC2.route_table(
                vpc: @vpc_id
              )
              resources[@route_id] = Resources::EC2.route(
                route_table: @route_table_id,
                instance: @instance_id
              )
            end

            private(
              :_set_os,
              :_set_source_dest_check,
              :_add_setup_script,
              :_add_route_table
            )
          end
        end
      end
    end
  end
end
