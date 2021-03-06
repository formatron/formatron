require_relative 'subnet/nat'
require_relative 'subnet/bastion'
require_relative 'subnet/chef_server'
require_relative 'subnet/instance'
require_relative 'subnet/acl'
require_relative '../vpc'
require 'formatron/cloud_formation/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # generates CloudFormation subnet resources
        # rubocop:disable Metrics/ClassLength
        class Subnet
          SUBNET_PREFIX = 'subnet'
          SUBNET_ROUTE_TABLE_ASSOCIATION_PREFIX = 'subnetRouteTableAssociation'

          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          # rubocop:disable Metrics/AbcSize
          def initialize(
            subnet:,
            external:,
            vpc_guid:,
            vpc_cidr:,
            key_pair:,
            administrator_name:,
            administrator_password:,
            hosted_zone_name:,
            kms_key:,
            nats:,
            private_hosted_zone_id:,
            public_hosted_zone_id:,
            bucket:,
            name:,
            target:
          )
            @subnet = subnet
            @external = external
            @vpc_guid = vpc_guid
            @vpc_cidr = vpc_cidr
            @cidr = @subnet.cidr
            @acl = @subnet.acl
            @key_pair = key_pair
            @administrator_name = administrator_name
            @administrator_password = administrator_password
            @hosted_zone_name = hosted_zone_name
            @kms_key = kms_key
            @nats = nats
            @private_hosted_zone_id = private_hosted_zone_id
            @public_hosted_zone_id = public_hosted_zone_id
            @bucket = bucket
            @name = name
            @target = target
          end
          # rubocop:enable Metrics/AbcSize
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          # rubocop:disable Metrics/MethodLength
          def merge(resources:, outputs:)
            @guid = @subnet.guid
            if @guid.nil?
              @guid = @external.guid
              _merge_external resources: resources, outputs: outputs
            else
              _merge_local resources: resources, outputs: outputs
            end
          end

          def _merge_external(resources:, outputs:)
            @gateway = @external.gateway
            @availability_zone = @external.availability_zone
            {
              nat: NAT,
              bastion: Bastion,
              chef_server: ChefServer,
              instance: Instance
            }.each do |symbol, cls|
              @subnet.send(symbol).each do |_, instance|
                args = {
                  symbol => instance,
                  key_pair: @key_pair,
                  administrator_name: @administrator_name,
                  administrator_password: @administrator_password,
                  availability_zone: @availability_zone,
                  subnet_guid: @guid,
                  hosted_zone_name: @hosted_zone_name,
                  vpc_guid: @vpc_guid,
                  vpc_cidr: @vpc_cidr,
                  kms_key: @kms_key,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  public_hosted_zone_id:
                    @gateway.nil? ? @public_hosted_zone_id : nil,
                  bucket: @bucket,
                  name: @name,
                  target: @target
                }
                instance = cls.new(**args)
                instance.merge resources: resources, outputs: outputs
              end
            end
          end

          def _merge_local(resources:, outputs:)
            @subnet_id = "#{SUBNET_PREFIX}#{@guid}"
            @subnet_route_table_association_id =
              "#{SUBNET_ROUTE_TABLE_ASSOCIATION_PREFIX}#{@guid}"
            @vpc_id = "#{VPC::VPC_PREFIX}#{@vpc_guid}"
            @public_route_table_id =
              "#{VPC::ROUTE_TABLE_PREFIX}#{@vpc_guid}"
            @gateway = @subnet.gateway
            @availability_zone = @subnet.availability_zone
            {
              nat: NAT,
              bastion: Bastion,
              chef_server: ChefServer,
              instance: Instance
            }.each do |symbol, cls|
              @subnet.send(symbol).each do |_, instance|
                args = {
                  symbol => instance,
                  key_pair: @key_pair,
                  administrator_name: @administrator_name,
                  administrator_password: @administrator_password,
                  availability_zone: @availability_zone,
                  subnet_guid: @guid,
                  hosted_zone_name: @hosted_zone_name,
                  vpc_guid: @vpc_guid,
                  vpc_cidr: @vpc_cidr,
                  kms_key: @kms_key,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  public_hosted_zone_id:
                    @gateway.nil? ? @public_hosted_zone_id : nil,
                  bucket: @bucket,
                  name: @name,
                  target: @target
                }
                instance = cls.new(**args)
                instance.merge resources: resources, outputs: outputs
              end
            end
            _add_subnet resources, outputs
            _add_subnet_route_table_association resources
            _add_acl resources if @acl && @gateway.nil?
          end
          # rubocop:enable Metrics/MethodLength

          def _add_subnet(resources, outputs)
            resources[@subnet_id] = Resources::EC2.subnet(
              vpc: @vpc_id,
              cidr: @cidr,
              availability_zone: @availability_zone,
              map_public_ip_on_launch: @gateway.nil?
            )
            outputs[@subnet_id] = Template.output Template.ref(@subnet_id)
          end

          def _add_subnet_route_table_association(resources)
            route_table = @public_route_table_id
            unless @gateway.nil?
              gateway_guid = @nats[@gateway].guid
              route_table = "#{NAT::ROUTE_TABLE_PREFIX}#{gateway_guid}"
            end
            resources[@subnet_route_table_association_id] =
              Resources::EC2.subnet_route_table_association(
                route_table: route_table,
                subnet: @subnet_id
              )
          end

          def _add_acl(resources)
            acl = ACL.new(
              acl: @acl,
              subnet_guid: @guid,
              vpc_guid: @vpc_guid,
              vpc_cidr: @vpc_cidr
            )
            acl.merge resources: resources
          end

          private(
            :_merge_local,
            :_merge_external,
            :_add_subnet,
            :_add_subnet_route_table_association,
            :_add_acl
          )
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
