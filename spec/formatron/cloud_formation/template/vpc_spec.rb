require 'spec_helper'
require 'formatron/cloud_formation/template/vpc'

class Formatron
  module CloudFormation
    # rubocop:disable Metrics/ClassLength
    class Template
      describe VPC do
        include TemplateTest

        before :each do
          @ec2 = class_double(
            'Formatron::CloudFormation::Resources::EC2'
          ).as_stubbed_const
          @route53 = class_double(
            'Formatron::CloudFormation::Resources::Route53'
          ).as_stubbed_const
          @results = {}
          @dsl_instances = {}
          @guid = 'guid'
          @private_hosted_zone_id = "hostedZone#{@guid}"
          @cidr = 'cidr'
          @key_pair = 'key_pair'
          @administrator_name = 'administrator_name'
          @administrator_password = 'administrator_password'
          @hosted_zone_name = 'hosted_zone_name'
          @kms_key = 'kms_key'
          @nats = 'nats'
          @hosted_zone_id = 'hosted_zone_id'
          @bucket = 'bucket'
          @name = 'name'
          @target = 'target'
          test_instances(
            tag: :subnet,
            args: lambda do |_|
              {
                external: nil,
                vpc_guid: @guid,
                vpc_cidr: @cidr,
                key_pair: @key_pair,
                administrator_name: @administrator_name,
                administrator_password: @administrator_password,
                hosted_zone_name: @hosted_zone_name,
                kms_key: @kms_key,
                nats: @nats,
                private_hosted_zone_id: @private_hosted_zone_id,
                public_hosted_zone_id: @hosted_zone_id,
                bucket: @bucket,
                name: @name,
                target: @target
              }
            end,
            template_cls: 'Formatron::CloudFormation::Template::VPC::Subnet',
            dsl_cls: 'Formatron::DSL::Formatron::VPC::Subnet'
          )
          @external_vpc = instance_double 'Formatron::DSL::Formatron' \
                                          '::VPC'
          @dsl_vpc = instance_double 'Formatron::DSL::Formatron::VPC'
          allow(@dsl_vpc).to receive(
            :subnet
          ) { @dsl_instances[:subnet] }
          @vpc_util_class = class_double(
            'Formatron::Util::VPC'
          ).as_stubbed_const
          @template_vpc = VPC.new(
            vpc: @dsl_vpc,
            external: @external_vpc,
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
        end

        context 'when the VPC is defined in a dependency' do
          before :each do
            external_subnets = (0..9).each_with_object({}) do |i, o|
              o["subnet#{i}"] = "external_subnet#{i}"
            end
            test_instances(
              tag: :subnet,
              args: lambda do |key|
                {
                  external: external_subnets[key],
                  vpc_guid: @guid,
                  vpc_cidr: @cidr,
                  key_pair: @key_pair,
                  administrator_name: @administrator_name,
                  administrator_password: @administrator_password,
                  hosted_zone_name: @hosted_zone_name,
                  kms_key: @kms_key,
                  nats: @nats,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  public_hosted_zone_id: @hosted_zone_id,
                  bucket: @bucket,
                  name: @name,
                  target: @target
                }
              end,
              template_cls: 'Formatron::CloudFormation::Template::VPC::Subnet',
              dsl_cls: 'Formatron::DSL::Formatron::VPC::Subnet'
            )
            allow(@dsl_vpc).to receive(
              :subnet
            ) { @dsl_instances[:subnet] }
            allow(@external_vpc).to receive(
              :subnet
            ) { external_subnets }
            allow(@dsl_vpc).to receive(:guid) { nil }
            allow(@external_vpc).to receive(:guid) { @guid }
            allow(@external_vpc).to receive(:cidr) { @cidr }
            allow(@vpc_util_class).to receive(:instances).with(
              :nat,
              @external_vpc,
              @dsl_vpc
            ) { @nats }
          end

          describe '#merge' do
            before :each do
              @resources = {}
              @outputs = {}
              @template_vpc.merge resources: @resources, outputs: @outputs
            end

            it 'should add the subnets' do
              expect(@resources).to include @results
              expect(@outputs).to include @results
            end
          end
        end

        context 'when the VPC is defined locally' do
          before :each do
            allow(@dsl_vpc).to receive(:guid) { @guid }
            allow(@vpc_util_class).to receive(:instances).with(
              :nat,
              @dsl_vpc
            ) { @nats }
            allow(@dsl_vpc).to receive(:cidr) { @cidr }
            @vpc = 'vpc'
            allow(@ec2).to receive(:vpc).with(
              cidr: @cidr
            ) { @vpc }
            @internet_gateway = 'internet_gateway'
            allow(@ec2).to receive(:internet_gateway) { @internet_gateway }
            @logical_id = "vpc#{@guid}"
            @internet_gateway_id = "internetGateway#{@guid}"
            @vpc_gateway_attachment_id = "vpcGatewayAttachment#{@guid}"
            @vpc_gateway_attachment = 'vpc_gateway_attachment'
            allow(@ec2).to receive(:vpc_gateway_attachment).with(
              vpc: @logical_id,
              gateway: @internet_gateway_id
            ) { @vpc_gateway_attachment }
            @public_route_table_id = "routeTable#{@guid}"
            @public_route_table = 'public_route_table'
            allow(@ec2).to receive(:route_table).with(
              vpc: @logical_id
            ) { @public_route_table }
            @public_route_id = "route#{@guid}"
            @public_route = 'public_route'
            allow(@ec2).to receive(:route).with(
              vpc_gateway_attachment: @vpc_gateway_attachment_id,
              route_table: @public_route_table_id,
              internet_gateway: @internet_gateway_id
            ) { @public_route }
            @private_hosted_zone = 'private_hosted_zone'
            allow(@route53).to receive(:hosted_zone).with(
              name: @hosted_zone_name,
              vpc: @logical_id
            ) { @private_hosted_zone }
          end

          describe '#merge' do
            before :each do
              @resources = {}
              @outputs = {}
              @template_vpc.merge resources: @resources, outputs: @outputs
            end

            it 'should add the subnets' do
              expect(@resources).to include @results
              expect(@outputs).to include @results
            end

            it 'should add a VPC' do
              expect(@resources).to include(
                @logical_id => @vpc
              )
              expect(@outputs).to include(
                @logical_id => {
                  Value: { Ref: @logical_id }
                }
              )
            end

            it 'should add an internet gateway' do
              expect(@resources).to include(
                @internet_gateway_id => @internet_gateway
              )
            end

            it 'should add a VPC gateway attachment' do
              expect(@resources).to include(
                @vpc_gateway_attachment_id => @vpc_gateway_attachment
              )
            end

            it 'should add a public route table' do
              expect(@resources).to include(
                @public_route_table_id => @public_route_table
              )
            end

            it 'should add a public route' do
              expect(@resources).to include(
                @public_route_id => @public_route
              )
            end

            it 'should add a private hosted zone' do
              expect(@resources).to include(
                @private_hosted_zone_id => @private_hosted_zone
              )
              expect(@outputs).to include(
                @private_hosted_zone_id => {
                  Value: { Ref: @private_hosted_zone_id }
                }
              )
            end
          end
        end
      end
      # rubocop:enable Metrics/ClassLength
    end
  end
end
