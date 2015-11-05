require 'spec_helper'
require 'formatron/cloud_formation' \
        '/template/resources/iam'

class Formatron
  module CloudFormation
    module Template
      # namespacing for tests
      # rubocop:disable Metrics/ModuleLength
      module Resources
        describe IAM do
          describe '::role' do
            it 'should return a Role resource' do
              expect(IAM.role).to eql(
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
              )
            end
          end

          describe '::instance_profile' do
            it 'should return an InstanceProfile resource' do
              role = 'role'
              expect(IAM.instance_profile(role: role)).to eql(
                Type: 'AWS::IAM::InstanceProfile',
                Properties: {
                  Path: '/',
                  Roles: [
                    { Ref: role }
                  ]
                }
              )
            end
          end

          describe '::policy' do
            it 'should return a Policy resource' do
              role = 'role'
              name = 'name'
              statements = [{
                actions: 'actions1',
                resources: 'resources1'
              }, {
                actions: 'actions2',
                resources: 'resources3'
              }]
              expect(
                IAM.policy(
                  role: role,
                  name: name,
                  statements: statements
                )
              ).to eql(
                Type: 'AWS::IAM::Policy',
                Properties: {
                  Roles: [{ Ref: role }],
                  PolicyName: name,
                  PolicyDocument: {
                    Version: '2012-10-17',
                    Statement: [{
                      Effect: 'Allow',
                      Action: statements[0][:actions],
                      Resource: statements[0][:resources]
                    }, {
                      Effect: 'Allow',
                      Action: statements[1][:actions],
                      Resource: statements[1][:resources]
                    }]
                  }
                }
              )
            end
          end

          describe '::user' do
            it 'should return a User resource' do
              policy_name = 'policy_name'
              statements = [{
                actions: 'actions1',
                resources: 'resources1'
              }, {
                actions: 'actions2',
                resources: 'resources3'
              }]
              expect(
                IAM.user(
                  policy_name: policy_name,
                  statements: statements
                )
              ).to eql(
                Type: 'AWS::IAM::User',
                Properties: {
                  Path: '/',
                  Policies: [{
                    PolicyName: policy_name,
                    PolicyDocument: {
                      Version: '2012-10-17',
                      Statement: [{
                        Effect: 'Allow',
                        Action: statements[0][:actions],
                        Resource: statements[0][:resources]
                      }, {
                        Effect: 'Allow',
                        Action: statements[1][:actions],
                        Resource: statements[1][:resources]
                      }]
                    }
                  }]
                }
              )
            end
          end

          describe '::access_key' do
            it 'should return a AccessKey resource' do
              user_name = 'user_name'
              expect(
                IAM.access_key(
                  user_name: user_name
                )
              ).to eql(
                Type: 'AWS::IAM::AccessKey',
                Properties: {
                  UserName: user_name
                }
              )
            end
          end
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
