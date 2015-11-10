require 'formatron/cloud_formation/resources/iam'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # generates CloudFormation policy resource
            class Policy
              POLICY_PREFIX = 'policy'

              def initialize(policy:, instance_guid:, kms_key:)
                @policy = policy
                @kms_key = kms_key
                @guid = instance_guid
                @policy_id = "#{POLICY_PREFIX}#{@guid}"
                @role_id = "#{Instance::ROLE_PREFIX}#{@guid}"
              end

              # rubocop:disable Metrics/MethodLength
              def merge(resources:)
                resources[@policy_id] = Resources::IAM.policy(
                  role: @role_id,
                  name: @policy_id,
                  statements: [{
                    actions: %w(kms:Decrypt kms:Encrypt kms:GenerateDataKey*),
                    resources: [Template.join(
                      'arn:aws:kms:',
                      Template.ref('AWS::Region'),
                      ':',
                      Template.ref('AWS::AccountId'),
                      ":key/#{@kms_key}"
                    )]
                  }].concat(
                    @policy.statement.collect do |statement|
                      {
                        actions: statement.action,
                        resources: statement.resource
                      }
                    end
                  )
                )
              end
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
