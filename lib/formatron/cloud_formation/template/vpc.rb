require_relative 'vpc/subnet'
require 'formatron/cloud_formation/resources/ec2'
require 'formatron/cloud_formation/resources/route53'

class Formatron
  module CloudFormation
    class Template
      # generates CloudFormation VPC resources
      # rubocop:disable Metrics/ClassLength
      class VPC
        VPC_PREFIX = 'vpc'
        INTERNET_GATEWAY_PREFIX = 'internetGateway'
        VPC_GATEWAY_ATTACHMENT_PREFIX = 'vpcGatewayAttachment'
        ROUTE_TABLE_PREFIX = 'routeTable'
        ROUTE_PREFIX = 'route'
        HOSTED_ZONE_PREFIX = 'hostedZone'

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/ParameterLists
        def initialize(
          vpc:,
          hosted_zone_name:,
          key_pair:,
          kms_key:,
          nats:,
          hosted_zone_id:,
          bucket:,
          name:,
          target:
        )
          @vpc = vpc
          @hosted_zone_name = hosted_zone_name
          @key_pair = key_pair
          @kms_key = kms_key
          @nats = nats
          @hosted_zone_id = hosted_zone_id
          @bucket = bucket
          @name = name
          @target = target
        end
        # rubocop:enable Metrics/ParameterLists
        # rubocop:enable Metrics/MethodLength

        def merge(resources:, outputs:)
          @guid = @vpc.guid
          if @guid.nil?
            @external = @vpc.external
            @guid = @external.guid
            _merge_external resources: resources, outputs: outputs
          else
            _merge_local resources: resources, outputs: outputs
          end
        end

        # rubocop:disable Metrics/MethodLength
        def _merge_local(resources:, outputs:)
          @cidr = @vpc.cidr
          @logical_id = "#{VPC_PREFIX}#{@guid}"
          @internet_gateway_id = "#{INTERNET_GATEWAY_PREFIX}#{@guid}"
          @vpc_gateway_attachment_id =
            "#{VPC_GATEWAY_ATTACHMENT_PREFIX}#{@guid}"
          @route_table_id =
            "#{ROUTE_TABLE_PREFIX}#{@guid}"
          @route_id =
            "#{ROUTE_PREFIX}#{@guid}"
          @private_hosted_zone_id =
            "#{HOSTED_ZONE_PREFIX}#{@guid}"
          @vpc.subnet.each do |_, subnet|
            template_subnet = Subnet.new(
              subnet: subnet,
              vpc_guid: @guid,
              vpc_cidr: @cidr,
              key_pair: @key_pair,
              hosted_zone_name: @hosted_zone_name,
              kms_key: @kms_key,
              nats: @nats,
              private_hosted_zone_id: @private_hosted_zone_id,
              public_hosted_zone_id: @hosted_zone_id,
              bucket: @bucket,
              name: @name,
              target: @target
            )
            template_subnet.merge resources: resources, outputs: outputs
          end
          _add_vpc resources, outputs
          _add_internet_gateway resources
          _add_vpc_gateway_attachment resources
          _add_route_table resources
          _add_route resources
          _add_private_hosted_zone resources, outputs
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def _merge_external(resources:, outputs:)
          @cidr = @external.cidr
          @private_hosted_zone_id =
            "#{HOSTED_ZONE_PREFIX}#{@guid}"
          @vpc.subnet.each do |_, subnet|
            template_subnet = Subnet.new(
              subnet: subnet,
              vpc_guid: @guid,
              vpc_cidr: @cidr,
              key_pair: @key_pair,
              hosted_zone_name: @hosted_zone_name,
              kms_key: @kms_key,
              nats: @nats,
              private_hosted_zone_id: @private_hosted_zone_id,
              public_hosted_zone_id: @hosted_zone_id,
              bucket: @bucket,
              name: @name,
              target: @target
            )
            template_subnet.merge resources: resources, outputs: outputs
          end
        end
        # rubocop:enable Metrics/MethodLength

        def _add_vpc(resources, outputs)
          resources[@logical_id] = Resources::EC2.vpc cidr: @cidr
          outputs[@logical_id] = Template.output Template.ref(@logical_id)
        end

        def _add_internet_gateway(resources)
          resources[@internet_gateway_id] = Resources::EC2.internet_gateway
        end

        def _add_vpc_gateway_attachment(resources)
          resources[
            @vpc_gateway_attachment_id
          ] = Resources::EC2.vpc_gateway_attachment(
            vpc: @logical_id,
            gateway: @internet_gateway_id
          )
        end

        def _add_route_table(resources)
          resources[
            @route_table_id
          ] = Resources::EC2.route_table(
            vpc: @logical_id
          )
        end

        def _add_route(resources)
          resources[
            @route_id
          ] = Resources::EC2.route(
            vpc_gateway_attachment: @vpc_gateway_attachment_id,
            internet_gateway: @internet_gateway_id,
            route_table: @route_table_id
          )
        end

        def _add_private_hosted_zone(resources, outputs)
          resources[@private_hosted_zone_id] = Resources::Route53.hosted_zone(
            name: @hosted_zone_name,
            vpc: @logical_id
          )
          outputs[@private_hosted_zone_id] = Template.output(
            Template.ref(@private_hosted_zone_id)
          )
        end

        private(
          :_merge_local,
          :_merge_external,
          :_add_vpc,
          :_add_internet_gateway,
          :_add_vpc_gateway_attachment,
          :_add_route_table,
          :_add_route,
          :_add_private_hosted_zone
        )
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
