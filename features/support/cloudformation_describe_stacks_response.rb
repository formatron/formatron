class Formatron
  module Cucumber
    module Support
      # Stub CloudFormation describe_stacks response class
      class CloudformationDescribeStacksResponse
        attr_reader :stacks

        # Stub CloudFormation describe_stacks response.stacks class
        class Stack
          attr_reader :outputs, :stack_status

          # Stub CloudFormation describe_stacks response.stacks[N].outputs class
          class Output
            attr_reader :output_key, :output_value

            def initialize(output_key, output_value)
              @output_key = output_key
              @output_value = output_value
            end
          end

          def initialize(outputs, stack_status)
            @stack_status = stack_status
            @outputs = outputs.map do |output|
              Output.new output[:name], output[:value]
            end
          end
        end

        def initialize(outputs)
          @stacks = [
            Stack.new(outputs, 'CREATE_COMPLETE')
          ]
        end
      end
    end
  end
end
