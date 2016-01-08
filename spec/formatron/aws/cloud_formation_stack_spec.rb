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
        stub_const 'Formatron::LOG', Logger.new('/dev/null')
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
          expect(@aws_cloudformation_stack).to receive(:wait_until_exists)
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

          it 'should complete ok' do
            @cloudformation_stack.create(
              template_url: template_url,
              parameters: parameters
            )
          end
        end

        %w(
          CREATE_FAILED
          ROLLBACK_COMPLETE
          ROLLBACK_FAILED
        ).each do |failure|
          context "when the create fails with #{failure}" do
            before :each do
              allow(@aws_cloudformation_stack).to receive(
                :events
              ).and_return(
                *CloudformationStackEventsResponses.new(
                  stack_name: stack_name,
                  final_status: failure
                ).responses
              )
            end

            it 'should raise an error' do
              expect do
                @cloudformation_stack.create(
                  template_url: template_url,
                  parameters: parameters
                )
              end.to raise_error failure
            end
          end
        end
      end

      describe '#update' do
        before :each do
          expect(@aws_cloudformation_stack).to receive(:update).with(
            template_url: template_url,
            capabilities: %w(CAPABILITY_IAM),
            parameters: parameters
          )
        end

        context 'when the update completes successfully' do
          before :each do
            allow(@aws_cloudformation_stack).to receive(
              :events
            ).and_return(
              *CloudformationStackEventsResponses.new(
                stack_name: stack_name,
                final_status: 'UPDATE_COMPLETE'
              ).responses
            )
          end

          it 'should complete ok' do
            @cloudformation_stack.update(
              template_url: template_url,
              parameters: parameters
            )
          end
        end

        %w(
          UPDATE_ROLLBACK_COMPLETE
          UPDATE_ROLLBACK_FAILED
        ).each do |failure|
          context "when the update fails with #{failure}" do
            before :each do
              allow(@aws_cloudformation_stack).to receive(
                :events
              ).and_return(
                *CloudformationStackEventsResponses.new(
                  stack_name: stack_name,
                  final_status: failure
                ).responses
              )
            end

            it 'should raise an error' do
              expect do
                @cloudformation_stack.update(
                  template_url: template_url,
                  parameters: parameters
                )
              end.to raise_error failure
            end
          end
        end
      end

      describe '#delete' do
        before :each do
          expect(@aws_cloudformation_stack).to receive(:delete).with(
            no_args
          )
        end

        context 'when the delete completes successfully' do
          before :each do
            allow(@aws_cloudformation_stack).to receive(
              :events
            ).and_return(
              *CloudformationStackEventsResponses.new(
                stack_name: stack_name,
                final_status: 'DELETE_COMPLETE'
              ).responses
            )
          end

          it 'should complete ok' do
            @cloudformation_stack.delete
          end
        end

        %w(
          DELETE_FAILED
        ).each do |failure|
          context "when the delete fails with #{failure}" do
            before :each do
              allow(@aws_cloudformation_stack).to receive(
                :events
              ).and_return(
                *CloudformationStackEventsResponses.new(
                  stack_name: stack_name,
                  final_status: failure
                ).responses
              )
            end

            it 'should raise an error' do
              expect do
                @cloudformation_stack.delete
              end.to raise_error failure
            end
          end
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
