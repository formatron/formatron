require_relative 'template/vpc'
require_relative 'template/parameters'
require 'formatron/aws'

class Formatron
  module CloudFormation
    # generates a CloudFormation template
    class Template
      REGION_MAP = 'regionMap'

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        formatron:,
        external:,
        hosted_zone_name:,
        key_pair:,
        administrator_name:,
        administrator_password:,
        kms_key:,
        hosted_zone_id:,
        target:
      )
        @formatron = formatron
        @external = external
        @external_formatron = external.formatron
        @external_outputs = external.outputs
        @hosted_zone_name = hosted_zone_name
        @key_pair = key_pair
        @administrator_name = administrator_name
        @administrator_password = administrator_password
        @kms_key = kms_key
        @hosted_zone_id = hosted_zone_id
        @bucket = formatron.bucket
        @name = formatron.name
        @target = target
      end
      # rubocop:enable Metrics/ParameterLists
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def hash
        resources = {}
        outputs = {}
        parameters = {}
        @formatron.vpc.each do |key, vpc|
          template_vpc = VPC.new(
            vpc: vpc,
            external: @external_formatron.vpc[key],
            hosted_zone_name: @hosted_zone_name,
            key_pair: @key_pair,
            administrator_name: @administrator_name,
            administrator_password: @administrator_password,
            kms_key: @kms_key,
            hosted_zone_id: @hosted_zone_id,
            bucket: @bucket,
            name: @name,
            target: @target
          )
          template_vpc.merge resources: resources, outputs: outputs
        end
        template_parameters = Parameters.new keys: @external_outputs.hash.keys
        template_parameters.merge parameters: parameters
        {
          AWSTemplateFormatVersion: '2010-09-09',
          Description: "Formatron stack: #{@formatron.name}",
          Mappings: {
            REGION_MAP => AWS::REGIONS
          },
          Parameters: parameters,
          Resources: resources,
          Outputs: outputs
        }
      end
      # rubocop:enable Metrics/MethodLength

      def self.ref(logical_id)
        {
          Ref: logical_id
        }
      end

      def self.join(*items)
        {
          'Fn::Join' => [
            '', items
          ]
        }
      end

      def self.find_in_map(map, key, property)
        {
          'Fn::FindInMap' => [
            map,
            key,
            property
          ]
        }
      end

      def self.base_64(value)
        {
          'Fn::Base64' => value
        }
      end

      def self.get_attribute(resource, attribute)
        {
          'Fn::GetAtt' => [resource, attribute]
        }
      end

      def self.output(value)
        {
          Value: value
        }
      end
    end
  end
end
