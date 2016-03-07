require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/setup'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # namespacing for tests
          # rubocop:disable Metrics/ClassLength
          class Instance
            describe Setup do
              describe '#merge' do
                before :each do
                  @setup_script = 'setup_script'
                  @sub_domain = 'sub_domain'
                  @hosted_zone_name = 'hosted_zone_name'
                  @dsl_setup = instance_double(
                    'Formatron::DSL::Formatron::VPC::Subnet' \
                    '::Instance::Setup'
                  )
                  dsl_variables = {}
                  @dsl_scripts = []
                  @variables = []
                  (0..9).each do |index|
                    script = "script#{index}"
                    @dsl_scripts.push script
                    value = "value#{index}"
                    key = "key#{index}"
                    @variables.push(
                      value: value,
                      key: key
                    )
                    dsl_variable = instance_double(
                      'Formatron::DSL::Formatron::VPC::Subnet' \
                      '::Instance::Setup::Variable'
                    )
                    allow(dsl_variable).to receive(
                      :value
                    ) { value }
                    dsl_variables[key] = dsl_variable
                  end
                  allow(@dsl_setup).to receive(
                    :script
                  ) { @dsl_scripts }
                  allow(@dsl_setup).to receive(
                    :variable
                  ) { dsl_variables }
                end

                context 'when os is linux' do
                  before :each do
                    os = 'os'
                    @files = {
                      '/tmp/formatron/script-0.sh' => {
                        content: @setup_script,
                        mode: '000755',
                        owner: 'root',
                        group: 'root'
                      }
                    }
                    variables_file_content = []
                    (0..9).each do |index|
                      @files["/tmp/formatron/script-#{index + 1}.sh"] = {
                        content: @dsl_scripts[index],
                        mode: '000755',
                        owner: 'root',
                        group: 'root'
                      }
                      variable = @variables[index]
                      variables_file_content.concat([
                        "#{variable[:key]}=",
                        variable[:value],
                        "\n"
                      ])
                    end
                    @files['/tmp/formatron/script-variables'] = {
                      content: { 'Fn::Join' => ['', variables_file_content] },
                      mode: '000644',
                      owner: 'root',
                      group: 'root'
                    }
                    scripts_class = class_double(
                      'Formatron::CloudFormation::Scripts'
                    ).as_stubbed_const
                    allow(scripts_class).to receive(:linux_common).with(
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name
                    ) { @setup_script }
                    template_setup = Setup.new(
                      setup: @dsl_setup,
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name,
                      os: os
                    )
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

                context 'when os is windows' do
                  before :each do
                    os = 'windows'
                    @files = {
                      'C:\formatron\script-0.bat' => {
                        content: @setup_script
                      }
                    }
                    variables_file_content = []
                    (0..9).each do |index|
                      @files["C:\\formatron\\script-#{index + 1}.bat"] = {
                        content: @dsl_scripts[index]
                      }
                      variable = @variables[index]
                      variables_file_content.concat([
                        "#{variable[:key]}=",
                        variable[:value],
                        "\n"
                      ])
                    end
                    @files['C:\formatron\script-variables.bat'] = {
                      content: { 'Fn::Join' => ['', variables_file_content] }
                    }
                    scripts_class = class_double(
                      'Formatron::CloudFormation::Scripts'
                    ).as_stubbed_const
                    allow(scripts_class).to receive(:windows_common).with(
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name
                    ) { @setup_script }
                    template_setup = Setup.new(
                      setup: @dsl_setup,
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name,
                      os: os
                    )
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
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
