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
        @aws_cloudformation_client = instance_double(
          'Aws::CloudFormation::Client'
        )
        @aws_cloudformation_stack = instance_double(
          'Aws::CloudFormation::Stack'
        )
        aws_cloudformation_stack_class = class_double(
          'Aws::CloudFormation::Stack'
        ).as_stubbed_const
        expect(aws_cloudformation_stack_class).to receive(:new).with(
          stack_name,
          client: @aws_cloudformation_client
        ) { @aws_cloudformation_stack }
        @cloudformation_stack = CloudFormationStack.new(
          stack_name: stack_name,
          client: @aws_cloudformation_client
        )
      end

      describe '#exists?' do
        context 'when the stack does not exist' do
          before :each do
            allow(@aws_cloudformation_stack).to receive(
              :exists?
            ) { false }
          end

          it 'should return false' do
            expect(
              @cloudformation_stack.exists?
            ).to eql false
          end
        end

        context 'when the stack exists' do
          before :each do
            allow(@aws_cloudformation_stack).to receive(
              :exists?
            ) { true }
          end

          it 'should return true' do
            expect(
              @cloudformation_stack.exists?
            ).to eql true
          end
        end
      end

      describe '#create' do
        before :each do
          expect(@aws_cloudformation_client).to receive(:create_stack).with(
            stack_name: stack_name,
            template_url: template_url,
            capabilities: %w(CAPABILITY_IAM),
            on_failure: 'DO_NOTHING',
            parameters: parameters
          )
        end

        context 'when the create completes successfully' do
          before :each do
            allow(@aws_cloudformation_stack).to receive(
              :events
            ).and_return(
              *CloudformationStackEventsResponses.new(
                stack_name: stack_name,
                final_status: 'CREATE_COMPLETE'
              ).responses
            )
          end

          it 'should create a stack and wait for the operation to finish' do
            expect(
              @cloudformation_stack.create(
                template_url: template_url,
                parameters: parameters
              )
            ).to eql true
          end
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
