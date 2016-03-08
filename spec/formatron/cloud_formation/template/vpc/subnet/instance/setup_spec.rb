require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/setup'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
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
                  @env = {}
                  (0..9).each do |index|
                    script = "script#{index}"
                    @dsl_scripts.push script
                    value = "value#{index}"
                    key = "key#{index}"
                    @env[key] = value
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
                    @commands = {
                      'script-0' => {
                        command: '/tmp/formatron/script-0.sh',
                        env: @env
                      }
                    }
                    (0..9).each do |index|
                      @files["/tmp/formatron/script-#{index + 1}.sh"] = {
                        content: @dsl_scripts[index],
                        mode: '000755',
                        owner: 'root',
                        group: 'root'
                      }
                      @commands["script-#{index + 1}"] = {
                        command: "/tmp/formatron/script-#{index + 1}.sh",
                        env: @env
                      }
                    end
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
                            files: @files,
                            commands: @commands
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
                    # note that we wait forever for completion of the first
                    # script because it causes a reboot
                    @commands = {
                      'script-0' => {
                        command: 'C:\formatron\script-0.bat',
                        env: @env,
                        waitAfterCompletion: 'forever'
                      }
                    }
                    (0..9).each do |index|
                      @files["C:\\formatron\\script-#{index + 1}.bat"] = {
                        content: @dsl_scripts[index]
                      }
                      @commands["script-#{index + 1}"] = {
                        command: "C:\\formatron\\script-#{index + 1}.bat",
                        env: @env
                      }
                    end
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
                            files: @files,
                            commands: @commands
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
