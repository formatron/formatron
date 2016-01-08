require 'aws-sdk'

class Formatron
  class AWS
    # utilities for monitoring CloudFormation stack activities
    # rubocop:disable Metrics/ClassLength
    class CloudFormationStack
      CAPABILITIES = %w(CAPABILITY_IAM)

      CREATE_COMPLETE_STATUS = 'CREATE_COMPLETE'
      CREATE_FINAL_STATUSES = %W(
        #{CREATE_COMPLETE_STATUS}
        CREATE_FAILED
        ROLLBACK_COMPLETE
        ROLLBACK_FAILED
      )

      UPDATE_COMPLETE_STATUS = 'UPDATE_COMPLETE'
      UPDATE_FINAL_STATUSES = %W(
        #{UPDATE_COMPLETE_STATUS}
        UPDATE_ROLLBACK_COMPLETE
        UPDATE_ROLLBACK_FAILED
      )

      DELETE_COMPLETE_STATUS = 'DELETE_COMPLETE'
      DELETE_FINAL_STATUSES = %W(
        #{DELETE_COMPLETE_STATUS}
        DELETE_FAILED
      )

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
        status = _wait_for_status statuses: CREATE_FINAL_STATUSES
        fail status unless status.eql? CREATE_COMPLETE_STATUS
      end

      def update(template_url:, parameters:)
        last_event_id = _last_event_id
        _update_unless_no_changes(
          template_url: template_url,
          parameters: parameters
        )
        status = _wait_for_status(
          statuses: UPDATE_FINAL_STATUSES,
          last_event_id: last_event_id
        )
        fail status unless status.eql? UPDATE_COMPLETE_STATUS
      end

      # rubocop:disable Metrics/MethodLength
      def _update_unless_no_changes(template_url:, parameters:)
        @stack.update(
          template_url: template_url,
          parameters: parameters,
          capabilities: CAPABILITIES
        )
      rescue Aws::CloudFormation::Errors::ValidationError => error
        raise error unless error.message.eql?(
          'No updates are to be performed.'
        )
        Formatron::LOG.info do
          'No updates are to be performed for CloudFormation stack'
        end
      end
      # rubocop:enable Metrics/MethodLength

      def delete
        last_event_id = _last_event_id
        @stack.delete
        status = _wait_for_status(
          statuses: DELETE_FINAL_STATUSES,
          last_event_id: last_event_id
        )
        fail status unless status.eql? DELETE_COMPLETE_STATUS
      end

      def _last_event_id
        @stack.events.each do |event|
          return event.event_id
        end
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
        :_update_unless_no_changes,
        :_last_event_id,
        :_wait_for_status
      )
    end
    # rubocop:enable Metrics/ClassLength
  end
end
