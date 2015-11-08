require_relative 'vpc/subnet'

class Formatron
  module CloudFormation
    class Template
      # generates CloudFormation VPC resources
      class VPC
        PREFIX = 'vpc'

        def initialize(vpc:)
          @vpc = vpc
        end

        def merge(resources:, outputs:)
          @vpc.subnet.each do |_, subnet|
            template_subnet = Subnet.new subnet: subnet
            template_subnet.merge resources: resources, outputs: outputs
          end
        end
      end
    end
  end
end
