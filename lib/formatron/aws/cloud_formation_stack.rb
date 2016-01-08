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
    end
  end
end
