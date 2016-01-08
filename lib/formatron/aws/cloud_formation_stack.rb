require 'aws-sdk'

class Formatron
  class AWS
    # utilities for monitoring CloudFormation stack activities
    class CloudFormationStack
      CAPABILITIES = %w(CAPABILITY_IAM)

      def initialize(stack_name:, client:)
        @stack_name = stack_name
        @client = client
        @stack = Aws::CloudFormation::Stack.new(
          stack_name,
          client: @client
        )
      end

      def exists?
        @stack.exists?
      end

      def create(template_url:, parameters:)
        @client.create_stack(
          stack_name: @stack_name,
          template_url: template_url,
          capabilities: CAPABILITIES,
          on_failure: 'DO_NOTHING',
          parameters: parameters
        )
        @stack.wait_until_exists
        _wait_for_status statuses: %w(CREATE_COMPLETE)
        true
      end

      def update(template_url:, parameters:)
        puts template_url
        puts parameters
        true
      end

      def delete
        true
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def _wait_for_status(statuses:, last_event_id: nil)
        loop do
          events = []
          @stack.events.each do |event|
            break if event.event_id.eql? last_event_id
            events.push event
          end
          events.reverse!
          events.each do |event|
            status = event.resource_status
            timestamp = event.timestamp
            type = event.resource_type
            logical_id = event.logical_resource_id
            reason = event.resource_status_reason
            Formatron::LOG.info do
              "#{timestamp} - #{status} - #{type} - #{logical_id} - #{reason}"
            end
            return status if
              statuses.include?(status) &&
              logical_id.eql?(@stack_name) &&
              type.eql?('AWS::CloudFormation::Stack')
            last_event_id = event.event_id
          end
          sleep 1
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private(
        :_wait_for_status
      )
    end
  end
end
