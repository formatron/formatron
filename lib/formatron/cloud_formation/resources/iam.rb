require_relative '../template'

class Formatron
  module CloudFormation
    module Resources
      # Generates CloudFormation template IAM resources
      module IAM
        # rubocop:disable Metrics/MethodLength
        def self.role
          {
            Type: 'AWS::IAM::Role',
            Properties: {
              AssumeRolePolicyDocument: {
                Version: '2012-10-17',
                Statement: [{
                  Effect: 'Allow',
                  Principal: { Service: ['ec2.amazonaws.com'] },
                  Action: ['sts:AssumeRole']
                }]
              },
              Path: '/'
            }
          }
        end
        # rubocop:enable Metrics/MethodLength

        def self.instance_profile(role:)
          {
            Type: 'AWS::IAM::InstanceProfile',
            Properties: {
              Path: '/',
              Roles: [Template.ref(role)]
            }
          }
        end

        # rubocop:disable Metrics/MethodLength
        def self.policy(role:, name:, statements:)
          {
            Type: 'AWS::IAM::Policy',
            Properties: {
              Roles: [Template.ref(role)],
              PolicyName: name,
              PolicyDocument: {
                Version: '2012-10-17',
                Statement: statements.collect do |statement|
                  {
                    Effect: 'Allow',
                    Action: statement[:actions],
                    Resource: statement[:resources]
                  }
                end
              }
            }
          }
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def self.user(policy_name:, statements:)
          {
            Type: 'AWS::IAM::User',
            Properties: {
              Path: '/',
              Policies: [{
                PolicyName: policy_name,
                PolicyDocument: {
                  Version: '2012-10-17',
                  Statement: statements.collect do |statement|
                    {
                      Effect: 'Allow',
                      Action: statement[:actions],
                      Resource: statement[:resources]
                    }
                  end
                }
              }]
            }
          }
        end
        # rubocop:enable Metrics/MethodLength

        def self.access_key(user_name:)
          {
            Type: 'AWS::IAM::AccessKey',
            Properties: {
              UserName: user_name
            }
          }
        end
      end
    end
  end
end
