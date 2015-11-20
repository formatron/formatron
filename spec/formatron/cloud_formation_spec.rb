require 'spec_helper'
require 'formatron/cloud_formation'

# rubocop:disable Metrics/ClassLength
class Formatron
  describe CloudFormation do
    before(:each) do
      stub_const 'Formatron::LOG', Logger.new('/dev/null')
      @region = 'region'
      @bucket = 'bucket'
      @name = 'name'
      @target = 'target'
      @parameters = 'parameters'
      @url = 'url'
      @aws = instance_double 'Formatron::AWS'
      allow(@aws).to receive(:region) { @region }
      @s3_cloud_formation_template = class_double(
        'Formatron::S3::CloudFormationTemplate'
      ).as_stubbed_const
    end

    describe '::deploy' do
      it 'should create the CloudFormation stack' do
        expect(@s3_cloud_formation_template).to receive(:url).once.with(
          region: @region,
          bucket: @bucket,
          name: @name,
          target: @target
        ) { @url }
        expect(@aws).to receive(:deploy_stack).once.with(
          stack_name: "#{@name}-#{@target}",
          template_url: @url,
          parameters: @parameters
        )
        CloudFormation.deploy(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          parameters: @parameters
        )
      end
    end

    describe '::destroy' do
      it 'should delete the CloudFormation stack' do
        expect(@aws).to receive(:delete_stack).once.with(
          stack_name: "#{@name}-#{@target}"
        )
        CloudFormation.destroy(
          aws: @aws,
          name: @name,
          target: @target
        )
      end
    end

    describe '::outputs' do
      context 'when there is a CloudFormation stack' do
        before :each do
          allow(@s3_cloud_formation_template).to receive(
            :exists?
          ) { true }
        end

        it 'should return the outputs of the CloudFormation stack' do
          outputs = 'outputs'
          expect(@aws).to receive(:stack_outputs).once.with(
            stack_name: "#{@name}-#{@target}"
          ) { outputs }
          expect(
            CloudFormation.outputs(
              aws: @aws,
              bucket: @bucket,
              name: @name,
              target: @target
            )
          ).to eql outputs
        end
      end

      context 'when there is no CloudFormation stack' do
        before :each do
          allow(@s3_cloud_formation_template).to receive(
            :exists?
          ) { false }
        end

        it 'should return an empty hash' do
          expect(
            CloudFormation.outputs(
              aws: @aws,
              bucket: @bucket,
              name: @name,
              target: @target
            )
          ).to eql({})
        end
      end
    end

    describe '::stack_ready!' do
      context 'when the stack is not ready' do
        before :each do
          expect(@aws).to receive(:stack_ready!).once.with(
            stack_name: "#{@name}-#{@target}"
          ) { fail 'not ready' }
        end

        it 'should raise an error' do
          expect do
            CloudFormation.stack_ready!(
              aws: @aws,
              name: @name,
              target: @target
            )
          end.to raise_error 'not ready'
        end
      end

      context 'when the stack is ready' do
        before :each do
          expect(@aws).to receive(:stack_ready!).once.with(
            stack_name: "#{@name}-#{@target}"
          )
        end

        it 'should do nothing' do
          CloudFormation.stack_ready!(
            aws: @aws,
            name: @name,
            target: @target
          )
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
