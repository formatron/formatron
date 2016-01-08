require 'aws-sdk'

class Formatron
  module Support
    # Stub CloudFormation describe_stacks response class
    class CloudformationStackEventsResponses
      include RSpec::Mocks::ExampleMethods

      attr_reader :responses

      # rubocop:disable Metrics/MethodLength
      def initialize(stack_name:, final_status:)
        @next_event_id = 0
        first_response = [
          event,
          event,
          event
        ]
        second_response = [
          event,
          event,
          event,
          *first_response
        ]
        third_response = [
          event(
            logical_resource_id: stack_name,
            resource_status: final_status,
            resource_type: 'AWS::CloudFormation::Stack'
          ),
          event,
          event,
          *second_response
        ]
        @responses = [
          first_response,
          second_response,
          third_response
        ]
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def event(
        logical_resource_id: 'logical_resource_id',
        resource_status: 'resource_status',
        resource_type: 'resource_type'
      )
        event = instance_double(Aws::CloudFormation::Event)
        allow(event).to receive(:logical_resource_id) { logical_resource_id }
        allow(event).to receive(:resource_status) { resource_status }
        allow(event).to receive(:resource_type) { resource_type }
        allow(event).to receive(:timestamp) { 'timestamp' }
        allow(event).to receive(
          :resource_status_reason
        ) { 'resource_status_reason' }
        allow(event).to receive(:event_id) do
          @next_event_id += 1
        end
        event
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
