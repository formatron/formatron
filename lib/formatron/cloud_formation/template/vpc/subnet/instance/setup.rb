require 'formatron/cloud_formation/scripts'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # Adds setup scripts to an instance
            # rubocop:disable Metrics/ClassLength
            class Setup
              # rubocop:disable Metrics/MethodLength
              def initialize(
                setup:,
                sub_domain:,
                hosted_zone_name:,
                os:,
                wait_condition_handle:
              )
                @setup = setup
                @wait_condition_handle = wait_condition_handle
                @sub_domain = sub_domain
                @hosted_zone_name = hosted_zone_name
                @scripts = @setup.script unless @setup.nil?
                @variables = @setup.variable unless @setup.nil?
                @os = os
              end
              # rubocop:enable Metrics/MethodLength

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
                  signal_script_index = @scripts.nil? ? 1 : @scripts.length + 1
                  script_key = "script-#{signal_script_index}"
                  script = "C:\\formatron\\#{script_key}.bat"
                  files[script] = {
                    content: Scripts.windows_signal(
                      wait_condition_handle: @wait_condition_handle
                    )
                  }
                  commands[script_key] = {
                    command: script,
                    env: env
                  }
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
            # rubocop:enable Metrics/ClassLength
          end
        end
      end
    end
  end
end
