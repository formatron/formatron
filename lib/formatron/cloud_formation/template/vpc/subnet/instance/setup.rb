class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # Adds setup scripts to an instance
            class Setup
              def initialize(setup:)
                @setup = setup
                @scripts = @setup.script
                @variables = @setup.variable
              end

              # rubocop:disable Metrics/MethodLength
              def merge(instance:)
                files = {}
                @scripts.each_index do |index|
                  files["/tmp/formatron/script-#{index}.sh"] = {
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
