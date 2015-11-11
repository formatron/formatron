require 'spec_helper'
require 'formatron/cloud_formation/template'

class Formatron
  # namespacing tests
  module CloudFormation
    describe Template do
      include TemplateTest

      before :each do
        @results = {}
        @dsl_instances = {}
        hosted_zone_name = 'hosted_zone_name'
        key_pair = 'key_pair'
        kms_key = 'kms_key'
        gateways = 'gateways'
        hosted_zone_id = 'hosted_zone_id'
        bucket = 'bucket'
        @name = 'name'
        target = 'target'
        test_instances(
          tag: :vpc,
          args: {
            hosted_zone_name: hosted_zone_name,
            key_pair: key_pair,
            kms_key: kms_key,
            gateways: gateways,
            hosted_zone_id: hosted_zone_id,
            bucket: bucket,
            name: @name,
            target: target
          },
          template_cls: 'Formatron::CloudFormation::Template::VPC',
          dsl_cls: 'Formatron::DSL::Formatron::VPC'
        )
        formatron = instance_double 'Formatron::DSL::Formatron'
        allow(formatron).to receive(:vpc) { @dsl_instances[:vpc] }
        allow(formatron).to receive(:name) { @name }
        allow(formatron).to receive(:bucket) { bucket }
        stub_const('Formatron::AWS::REGIONS', 'regions')
        @template = Template.new(
          formatron: formatron,
          hosted_zone_name: hosted_zone_name,
          key_pair: key_pair,
          kms_key: kms_key,
          gateways: gateways,
          hosted_zone_id: hosted_zone_id,
          target: target
        )
      end

      it 'should add the VPCs' do
        expect(@template.hash).to eql(
          AWSTemplateFormatVersion: '2010-09-09',
          Description: "Formatron stack: #{@name}",
          Mappings: {
            'regionMap' => 'regions'
          },
          Resources: @results,
          Outputs: @results
        )
      end
    end
  end
end
