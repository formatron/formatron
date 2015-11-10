require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/setup'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe Setup do
              describe '#merge' do
                before :each do
                  @files = {}
                  dsl_setup = instance_double(
                    'Formatron::DSL::Formatron::VPC::Subnet' \
                    '::Instance::Setup'
                  )
                  variables_file_content = []
                  dsl_variables = {}
                  dsl_scripts = []
                  (0..9).each do |index|
                    script = "script#{index}"
                    @files["/tmp/formatron/script-#{index}.sh"] = {
                      content: script,
                      mode: '000755',
                      owner: 'root',
                      group: 'root'
                    }
                    dsl_scripts.push script
                    value = "value#{index}"
                    key = "key#{index}"
                    variables_file_content.concat(["#{key}=", value, "\n"])
                    dsl_variable = instance_double(
                      'Formatron::DSL::Formatron::VPC::Subnet' \
                      '::Instance::Setup::Variable'
                    )
                    allow(dsl_variable).to receive(
                      :value
                    ) { value }
                    dsl_variables[key] = dsl_variable
                  end
                  @files['/tmp/formatron/script-variables'] = {
                    content: { 'Fn::Join' => ['', variables_file_content] },
                    mode: '000644',
                    owner: 'root',
                    group: 'root'
                  }
                  allow(dsl_setup).to receive(
                    :script
                  ) { dsl_scripts }
                  allow(dsl_setup).to receive(
                    :variable
                  ) { dsl_variables }

                  template_setup = Setup.new setup: dsl_setup
                  @instance = {}
                  template_setup.merge instance: @instance
                end

                it 'should add the scripts and variables' do
                  expect(@instance).to include(
                    Metadata: {
                      Comment1: 'Create setup scripts',
                      'AWS::CloudFormation::Init' => {
                        config: {
                          files: @files
                        }
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
