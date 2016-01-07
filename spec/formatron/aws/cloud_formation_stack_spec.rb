require 'spec_helper'
require 'formatron/aws/cloud_formation_stack'

class Formatron
  # rubocop:disable Metrics/ClassLength
  class AWS
    describe CloudFormationStack do
      stack_name = 'stack_name'
      template_url = 'template_url'
      parameters = 'parameters'

      before :each do
        @cloudformation_client = instance_double('Aws::CloudFormation::Client')
        @cloudformation_stack = CloudFormationStack.new(
          stack_name: stack_name,
          client: @cloudformation_client
        )
      end

      describe '#exists?' do
        it 'should return whether the stack exists and has not been deleted' do
          expect(
            @cloudformation_stack.exists?
          ).to eql true
        end
      end

      describe '#create' do
        it 'should create a stack and wait for the operation to finish' do
          expect(
            @cloudformation_stack.create(
              template_url: template_url,
              parameters: parameters
            )
          ).to eql true
        end
      end

      describe '#update' do
        it 'should update a stack and wait for the operation to finish' do
          expect(
            @cloudformation_stack.update(
              template_url: template_url,
              parameters: parameters
            )
          ).to eql true
        end
      end

      describe '#delete' do
        it 'should delete a stack and  wait for the operation to finish' do
          expect(
            @cloudformation_stack.delete
          ).to eql true
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
