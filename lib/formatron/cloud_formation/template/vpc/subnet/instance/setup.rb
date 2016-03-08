require 'formatron/cloud_formation/scripts'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # Adds setup scripts to an instance
            class Setup
              def initialize(setup:, sub_domain:, hosted_zone_name:, os:)
                @setup = setup
                @sub_domain = sub_domain
                @hosted_zone_name = hosted_zone_name
                @scripts = @setup.script unless @setup.nil?
                @variables = @setup.variable unless @setup.nil?
                @os = os
              end

              # rubocop:disable Metrics/MethodLength
              # rubocop:disable Metrics/AbcSize
              def merge(instance:)
                env = {}
                @variables.each do |key, value|
                  env[key] = value.value
                end unless @variables.nil?
                if @os.eql? 'windows'
                  script_key = 'script-0'
                  script = "C:\\formatron\\#{script_key}.bat"
                  files = {
                    "#{script}" => {
                      content: Scripts.windows_common(
                        sub_domain: @sub_domain,
                        hosted_zone_name: @hosted_zone_name
                      )
                    }
                  }
                  commands = {
                    "#{script_key}" => {
                      command: script,
                      env: env,
                      waitAfterCompletion: 'forever'
                    }
                  }
                  @scripts.each_index do |index|
                    script_key = "script-#{index + 1}"
                    script = "C:\\formatron\\#{script_key}.bat"
                    files[script] = {
                      content: @scripts[index]
                    }
                    commands[script_key] = {
                      command: script,
                      env: env
                    }
                  end unless @scripts.nil?
                else
                  script_key = 'script-0'
                  script = "/tmp/formatron/#{script_key}.sh"
                  files = {
                    "#{script}" => {
                      content: Scripts.linux_common(
                        sub_domain: @sub_domain,
                        hosted_zone_name: @hosted_zone_name
                      ),
                      mode: '000755',
                      owner: 'root',
                      group: 'root'
                    }
                  }
                  commands = {
                    "#{script_key}" => {
                      command: script,
                      env: env
                    }
                  }
                  @scripts.each_index do |index|
                    script_key = "script-#{index + 1}"
                    script = "/tmp/formatron/#{script_key}.sh"
                    files[script] = {
                      content: @scripts[index],
                      mode: '000755',
                      owner: 'root',
                      group: 'root'
                    }
                    commands[script_key] = {
                      command: script,
                      env: env
                    }
                  end unless @scripts.nil?
                end
                instance[:Metadata] = {
                  Comment1: 'Create setup scripts',
                  'AWS::CloudFormation::Init' => {
                    config: {
                      files: files,
                      commands: commands
                    }
                  }
                }
              end
              # rubocop:enable Metrics/AbcSize
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
