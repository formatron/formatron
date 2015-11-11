require 'formatron/cloud_formation/resources/iam'
require 'formatron/s3/configuration'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # generates CloudFormation policy resource
            class Policy
              POLICY_PREFIX = 'policy'

              # rubocop:disable Metrics/MethodLength
              # rubocop:disable Metrics/ParameterLists
              def initialize(
                policy:,
                instance_guid:,
                kms_key:,
                bucket:,
                name:,
                target:
              )
                @policy = policy
                @kms_key = kms_key
                @guid = instance_guid
                @bucket = bucket
                @config_key = S3::Configuration.key(
                  name: name,
                  target: target
                )
                @policy_id = "#{POLICY_PREFIX}#{@guid}"
                @role_id = "#{Instance::ROLE_PREFIX}#{@guid}"
              end
              # rubocop:enable Metrics/ParameterLists
              # rubocop:enable Metrics/MethodLength

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
                  }, {
                    actions: %w(S3:GetObject),
                    resources: ["arn:aws:s3:::#{@bucket}/#{@config_key}"]
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
