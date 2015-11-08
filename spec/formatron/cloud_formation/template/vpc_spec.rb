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
          @template_vpc = VPC.new vpc: formatronfile_vpc
        end

        describe '#merge' do
          it 'should add the subnets' do
            resources = {}
            outputs = {}
            @template_vpc.merge resources: resources, outputs: outputs
            expect(resources).to eql @results
            expect(outputs).to eql @results
          end
        end
      end
    end
  end
end
