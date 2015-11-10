require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/policy'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe Policy do
              describe '#merge' do
                before :each do
                  kms_key = 'kms_key'
                  guid = 'guid'
                  dsl_policy = instance_double(
                    'Formatron::DSL::Formatron::VPC::Subnet::Instance::Policy'
                  )

                  statements = [{
                    actions: %w(kms:Decrypt kms:Encrypt kms:GenerateDataKey*),
                    resources: [{
                      'Fn::Join' => [
                        '', [
                          'arn:aws:kms:',
                          { Ref: 'AWS::Region' },
                          ':',
                          { Ref: 'AWS::AccountId' },
                          ":key/#{kms_key}"
                        ]
                      ]
                    }]
                  }]
                  dsl_statements = []
                  (0..9).each do |index|
                    actions = []
                    resources = []
                    (0..9).each do |sub_index|
                      actions[sub_index] = "action_#{index}_#{sub_index}"
                      resources[sub_index] = "resources_#{index}_#{sub_index}"
                    end
                    statements.push(
                      actions: actions,
                      resources: resources
                    )
                    dsl_statement = instance_double(
                      'Formatron::DSL::Formatron::VPC:Subneti' \
                      '::Instance::Policy::Statement'
                    )
                    allow(dsl_statement).to receive(
                      :action
                    ) { actions }
                    allow(dsl_statement).to receive(
                      :resource
                    ) { resources }
                    dsl_statements[index] = dsl_statement
                  end
                  allow(dsl_policy).to receive(
                    :statement
                  ) { dsl_statements }

                  @role_id = "role#{guid}"
                  @policy_id = "policy#{guid}"
                  @policy = 'policy'
                  iam = class_double(
                    'Formatron::CloudFormation::Resources::IAM'
                  ).as_stubbed_const
                  allow(iam).to receive(:policy).with(
                    role: @role_id,
                    name: @policy_id,
                    statements: statements
                  ) { @policy }

                  template_policy = Policy.new(
                    policy: dsl_policy,
                    instance_guid: guid,
                    kms_key: kms_key
                  )
                  @resources = {}
                  template_policy.merge resources: @resources
                end

                it 'should add a policy' do
                  expect(@resources).to include(
                    @policy_id => @policy
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
