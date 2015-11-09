require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/policy'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # rubocop:disable Metrics/ClassLength
          class Instance
            describe Policy do
              describe '#merge' do
                before :each do
                  formatron = instance_double(
                    'Formatron'
                  )
                  kms_key = 'kms_key'
                  allow(formatron).to receive(:kms_key) { kms_key }
                  formatronfile = instance_double(
                    'Formatron::Formatronfile'
                  )
                  allow(formatronfile).to receive(
                    :dsl_parent
                  ) { formatron }
                  formatronfile_vpc = instance_double(
                    'Formatron::Formatronfile::VPC'
                  )
                  allow(formatronfile_vpc).to receive(
                    :dsl_parent
                  ) { formatronfile }
                  formatronfile_subnet = instance_double(
                    'Formatron::Formatronfile::VPC::Subnet'
                  )
                  allow(formatronfile_subnet).to receive(
                    :dsl_parent
                  ) { formatronfile_vpc }
                  formatronfile_instance = instance_double(
                    'Formatron::Formatronfile::VPC::Subnet::Instance'
                  )
                  allow(formatronfile_instance).to receive(
                    :dsl_parent
                  ) { formatronfile_subnet }
                  guid = 'guid'
                  allow(formatronfile_instance).to receive(:guid) { guid }
                  formatronfile_policy = instance_double(
                    'Formatron::Formatronfile::VPC::Subnet::Instance::Policy'
                  )
                  allow(formatronfile_policy).to receive(
                    :dsl_parent
                  ) { formatronfile_instance }

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
                  formatronfile_statements = []
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
                    formatronfile_statement = instance_double(
                      'Formatron::Formatronfile::VPC:Subneti' \
                      '::Instance::Policy::Statement'
                    )
                    allow(formatronfile_statement).to receive(
                      :action
                    ) { actions }
                    allow(formatronfile_statement).to receive(
                      :resource
                    ) { resources }
                    formatronfile_statements[index] = formatronfile_statement
                  end
                  allow(formatronfile_policy).to receive(
                    :statement
                  ) { formatronfile_statements }

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
                    policy: formatronfile_policy
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
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
