require_relative '../template'

class Formatron
  module CloudFormation
    module Resources
      # Generates CloudFormation template CloudFormation resources
      module CloudFormation
        def self.wait_condition_handle
          {
            Type: 'AWS::CloudFormation::WaitConditionHandle'
          }
        end

        def self.wait_condition(instance:, wait_condition_handle:)
          {
            Type: 'AWS::CloudFormation::WaitCondition',
            DependsOn: instance,
            Properties: {
              Handle: Template.ref(wait_condition_handle),
              Timeout: '1800'
            }
          }
        end
      end
    end
  end
end
