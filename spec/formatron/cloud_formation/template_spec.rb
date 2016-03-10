require 'spec_helper'
require 'formatron/cloud_formation/template'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module CloudFormation
    describe Template do
      include TemplateTest

      before :each do
        @results = {}
        @dsl_instances = {}
        hosted_zone_name = 'hosted_zone_name'
        key_pair = 'key_pair'
        administrator_name = 'administrator_name'
        administrator_password = 'administrator_password'
        kms_key = 'kms_key'
        hosted_zone_id = 'hosted_zone_id'
        bucket = 'bucket'
        @name = 'name'
        target = 'target'
        external_vpcs = {}
        test_instances(
          tag: :vpc,
          args: lambda do |dsl_key|
            {
              hosted_zone_name: hosted_zone_name,
              key_pair: key_pair,
              administrator_name: administrator_name,
              administrator_password: administrator_password,
              kms_key: kms_key,
              hosted_zone_id: hosted_zone_id,
              bucket: bucket,
              name: @name,
              target: target,
              external: "external_vpcs#{dsl_key}"
            }
          end,
          template_cls: 'Formatron::CloudFormation::Template::VPC',
          dsl_cls: 'Formatron::DSL::Formatron::VPC'
        )
        @dsl_instances[:vpc].keys.each do |dsl_key|
          external_vpcs[dsl_key] = "external_vpcs#{dsl_key}"
        end
        formatron = instance_double 'Formatron::DSL::Formatron'
        allow(formatron).to receive(:vpc) { @dsl_instances[:vpc] }
        allow(formatron).to receive(:name) { @name }
        allow(formatron).to receive(:bucket) { bucket }
        stub_const('Formatron::AWS::REGIONS', 'regions')
        external = instance_double 'Formatron::External'
        external_formatron = instance_double 'Formatron::DSL::Formatron'
        allow(external).to receive(:formatron) { external_formatron }
        allow(external_formatron).to receive(:vpc) { external_vpcs }
        external_outputs = instance_double 'Formatron::External::Outputs'
        external_outputs_hash = {
          'output1' => 'output1',
          'output2' => 'output2'
        }
        allow(external_outputs).to receive(:hash) { external_outputs_hash }
        allow(external).to receive(:outputs) { external_outputs }
        parameters_class = class_double(
          'Formatron::CloudFormation::Template::Parameters'
        ).as_stubbed_const
        template_parameters = instance_double(
          'Formatron::CloudFormation::Template::Parameters'
        )
        allow(parameters_class).to receive(:new).with(
          keys: external_outputs_hash.keys
        ) { template_parameters }
        allow(template_parameters).to receive(:merge) do |parameters:|
          parameters['output'] = 'output'
        end
        @template = Template.new(
          formatron: formatron,
          hosted_zone_name: hosted_zone_name,
          key_pair: key_pair,
          administrator_name: administrator_name,
          administrator_password: administrator_password,
          kms_key: kms_key,
          hosted_zone_id: hosted_zone_id,
          target: target,
          external: external
        )
      end

      it 'should add the boiler plate' do
        expect(@template.hash).to include(
          AWSTemplateFormatVersion: '2010-09-09',
          Description: "Formatron stack: #{@name}"
        )
      end

      it 'should add the region map' do
        expect(@template.hash).to include(
          Mappings: {
            'regionMap' => 'regions'
          }
        )
      end

      it 'should add the parameters' do
        expect(@template.hash).to include(
          Parameters: {
            'output' => 'output'
          }
        )
      end

      it 'should add the VPCs' do
        expect(@template.hash).to include(
          Resources: @results,
          Outputs: @results
        )
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
