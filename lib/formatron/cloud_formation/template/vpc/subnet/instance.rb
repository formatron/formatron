class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation instance resources
          class Instance
            def initialize(instance:)
              @instance = instance
            end

            def merge(resources:, outputs:)
              @resources = resources
              @outputs = outputs
            end
          end
        end
      end
    end
  end
end
