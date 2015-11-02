require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation' \
        '/template/resources/iam'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
          # namespacing for tests
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
            end
          end
        end
      end
    end
  end
end
