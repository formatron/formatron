class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation NAT resources
          class NAT
            def initialize(nat:)
              @nat = nat
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
