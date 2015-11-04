require 'spec_helper'
require 'formatron/s3_cloud_formation_template'
require 'formatron/cloud_formation_stack'

# namespacing for tests
class Formatron
  describe CloudFormationStack do
    before(:each) do
      @region = 'region'
      @bucket = 'bucket'
      @name = 'name'
      @target = 'target'
      @url = 'url'
      @aws = instance_double 'Formatron::AWS'
      allow(@aws).to receive(:region) { @region }
      @s3_cloud_formation_template = class_double(
        'Formatron::S3CloudFormationTemplate'
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
          template_url: @url
        )
        CloudFormationStack.deploy(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target
        )
      end
    end

    describe '::destroy' do
      it 'should delete the CloudFormation stack' do
        expect(@aws).to receive(:delete_stack).once.with(
          "#{@name}-#{@target}"
        )
        CloudFormationStack.destroy(
          aws: @aws,
          name: @name,
          target: @target
        )
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
            CloudFormationStack.stack_ready!(
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
          CloudFormationStack.stack_ready!(
            aws: @aws,
            name: @name,
            target: @target
          )
        end
      end
    end
  end
end
