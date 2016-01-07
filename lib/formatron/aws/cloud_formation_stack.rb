require 'aws-sdk'

class Formatron
  class AWS
    # utilities for monitoring CloudFormation stack activities
    class CloudFormationStack
      def initialize(stack_name:, client:)
        puts stack_name
        puts client
      end

      def exists?
        true
      end

      def create(template_url:, parameters:)
        puts template_url
        puts parameters
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
