require 'spec_helper'
require 'formatron/s3_cloud_formation_template'
require 'formatron/cloud_formation_stack'

# namespacing for tests
class Formatron
  describe CloudFormationStack do
    before(:each) do
      @region = 'region'
      @name = 'name'
      @target = 'target'
      @url = 'url'
      @aws = instance_double 'Formatron::AWS'
      allow(@aws).to receive(:region) { @region }
      @configuration = instance_double 'Formatron::Configuration'
      @s3_path = class_double(
        'Formatron::S3Path'
      ).as_stubbed_const
    end

    describe '::deploy' do
      it 'should create the CloudFormation stack' do
        expect(@s3_path).to receive(:url).once.with(
          region: @region,
          configuration: @configuration,
          target: @target,
          sub_path: S3CloudFormationTemplate::FILE_NAME
        ) { @url }
        expect(@configuration).to receive(:name).once.with(
          @target
        ) { @name }
        expect(@aws).to receive(:deploy_stack).once.with(
          stack_name: "#{@name}-#{@target}",
          template_url: @url
        )
        CloudFormationStack.deploy(
          aws: @aws,
          configuration: @configuration,
          target: @target
        )
      end
    end

    describe '::destroy' do
      it 'should delete the CloudFormation stack' do
        expect(@configuration).to receive(:name).once.with(
          @target
        ) { @name }
        expect(@aws).to receive(:delete_stack).once.with(
          "#{@name}-#{@target}"
        )
        CloudFormationStack.destroy(
          aws: @aws,
          configuration: @configuration,
          target: @target
        )
      end
    end
  end
end
