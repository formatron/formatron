require 'spec_helper'
require 'formatron/cloud_formation/template'

class Formatron
  # namespacing tests
  module CloudFormation
    describe Template do
      include TemplateTest

      before :each do
        @results = {}
        @formatronfile_instances = {}
        test_instances(
          tag: :vpc,
          template_cls: 'Formatron::CloudFormation::Template::VPC',
          formatronfile_cls: 'Formatron::Formatronfile::VPC'
        )
        formatronfile = instance_double 'Formatron::Formatronfile'
        allow(formatronfile).to receive(:vpc) { @formatronfile_instances[:vpc] }
        allow(formatronfile).to receive(:name) { 'name' }
        stub_const('Formatron::AWS::REGIONS', 'regions')
        @template = Template.new formatronfile: formatronfile
      end

      it 'should add the VPCs' do
        expect(@template.hash).to eql(
          AWSTemplateFormatVersion: '2010-09-09',
          Description: 'Formatron stack: name',
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
