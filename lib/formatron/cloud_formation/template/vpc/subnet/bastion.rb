class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation bastion resources
          class Bastion
            def initialize(bastion:)
              @bastion = bastion
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
