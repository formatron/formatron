require 'spec_helper'
require 'formatron/cloud_formation/template/vpc'

class Formatron
  module CloudFormation
    # namespacing tests
    class Template
      describe VPC do
        include TemplateTest

        before :each do
          @results = {}
          @formatronfile_instances = {}
          test_instances(
            tag: :subnet,
            template_cls: 'Formatron::CloudFormation::Template::VPC::Subnet',
            formatronfile_cls: 'Formatron::Formatronfile::VPC::Subnet'
          )
          formatronfile_vpc = instance_double 'Formatron::Formatronfile::VPC'
          allow(formatronfile_vpc).to receive(
            :subnet
          ) { @formatronfile_instances[:subnet] }
          @ec2 = class_double(
            'Formatron::CloudFormation::Template::Resources::EC2'
          ).as_stubbed_const
          guid = 'guid'
          allow(formatronfile_vpc).to receive(:guid) { guid }
          cidr = 'cidr'
          allow(formatronfile_vpc).to receive(:cidr) { cidr }
          @vpc = 'vpc'
          allow(@ec2).to receive(:vpc).with(
            cidr: cidr
          ) { @vpc }
          @internet_gateway = 'internet_gateway'
          allow(@ec2).to receive(:internet_gateway) { @internet_gateway }
          @logical_id = "vpc#{guid}"
          @internet_gateway_id = "internetGateway#{guid}"
          @vpc_gateway_attachment_id = "vpcGatewayAttachment#{guid}"
          @vpc_gateway_attachment = 'vpc_gateway_attachment'
          allow(@ec2).to receive(:vpc_gateway_attachment).with(
            vpc: @logical_id,
            gateway: @internet_gateway_id
          ) { @vpc_gateway_attachment }
          @public_route_table_id = "publicRouteTable#{guid}"
          @public_route_table = 'public_route_table'
          allow(@ec2).to receive(:route_table).with(
            vpc: @logical_id
          ) { @public_route_table }
          @public_route_id = "publicRoute#{guid}"
          @public_route = 'public_route'
          allow(@ec2).to receive(:route).with(
            vpc_gateway_attachment: @vpc_gateway_attachment_id,
            route_table: @public_route_table_id,
            internet_gateway: @internet_gateway_id
          ) { @public_route }
          @template_vpc = VPC.new vpc: formatronfile_vpc
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
        end
      end
    end
  end
end
