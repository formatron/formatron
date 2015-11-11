require 'formatron/cloud_formation/scripts'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # Adds setup scripts to an instance
            class Setup
              def initialize(setup:, sub_domain:, hosted_zone_name:)
                @setup = setup
                @sub_domain = sub_domain
                @hosted_zone_name = hosted_zone_name
                @scripts = @setup.script
                @variables = @setup.variable
              end

              # rubocop:disable Metrics/MethodLength
              def merge(instance:)
                files = {
                  '/tmp/formatron/script-0.sh' => {
                    content: Scripts.hostname(
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name
                    ),
                    mode: '000755',
                    owner: 'root',
                    group: 'root'
                  }
                }
                @scripts.each_index do |index|
                  files["/tmp/formatron/script-#{index + 1}.sh"] = {
                    content: @scripts[index],
                    mode: '000755',
                    owner: 'root',
                    group: 'root'
                  }
                end
                variables = []
                @variables.each do |key, value|
                  variables.concat(["#{key}=", value.value, "\n"])
                end
                files['/tmp/formatron/script-variables'] = {
                  content: Template.join(*variables),
                  mode: '000644',
                  owner: 'root',
                  group: 'root'
                }
                instance[:Metadata] = {
                  Comment1: 'Create setup scripts',
                  'AWS::CloudFormation::Init' => {
                    config: {
                      files: files
                    }
                  }
                }
              end
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
