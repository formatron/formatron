require_relative 'vpc/subnet'
require 'formatron/cloud_formation/template/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      # generates CloudFormation VPC resources
      class VPC
        PREFIX = 'vpc'
        INTERNET_GATEWAY_PREFIX = 'internetGateway'
        VPC_GATEWAY_ATTACHMENT_PREFIX = 'vpcGatewayAttachment'
        PUBLIC_ROUTE_TABLE_PREFIX = 'publicRouteTable'
        PUBLIC_ROUTE_PREFIX = 'publicRoute'

        # rubocop:disable Metrics/MethodLength
        def initialize(vpc:)
          @vpc = vpc
          @cidr = vpc.cidr
          @guid = vpc.guid
          @logical_id = "#{PREFIX}#{@guid}"
          @internet_gateway_id = "#{INTERNET_GATEWAY_PREFIX}#{@guid}"
          @vpc_gateway_attachment_id =
            "#{VPC_GATEWAY_ATTACHMENT_PREFIX}#{@guid}"
          @public_route_table_id =
            "#{PUBLIC_ROUTE_TABLE_PREFIX}#{@guid}"
          @public_route_id =
            "#{PUBLIC_ROUTE_PREFIX}#{@guid}"
        end
        # rubocop:enable Metrics/MethodLength

        def merge(resources:, outputs:)
          @vpc.subnet.each do |_, subnet|
            template_subnet = Subnet.new subnet: subnet
            template_subnet.merge resources: resources, outputs: outputs
          end
          _add_vpc resources, outputs
          _add_internet_gateway resources
          _add_vpc_gateway_attachment resources
          _add_public_route_table resources
          _add_public_route resources
        end

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

        def _add_public_route_table(resources)
          resources[
            @public_route_table_id
          ] = Resources::EC2.route_table(
            vpc: @logical_id
          )
        end

        def _add_public_route(resources)
          resources[
            @public_route_id
          ] = Resources::EC2.route(
            vpc_gateway_attachment: @vpc_gateway_attachment_id,
            internet_gateway: @internet_gateway_id,
            route_table: @public_route_table_id
          )
        end

        private(
          :_add_vpc,
          :_add_internet_gateway,
          :_add_vpc_gateway_attachment,
          :_add_public_route_table,
          :_add_public_route
        )
      end
    end
  end
end
