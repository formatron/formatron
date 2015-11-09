require 'formatron/cloud_formation/resources/iam'
require_relative 'instance/policy'
require_relative 'instance/security_group'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # generates CloudFormation instance resources
          class Instance
            ROLE_PREFIX = 'role'

            def initialize(instance:)
              @instance = instance
              @guid = @instance.guid
              @role_id = "#{ROLE_PREFIX}#{@guid}"
              @policy = @instance.policy
              @security_group = @instance.security_group
            end

            def merge(resources:, outputs:)
              @outputs = outputs
              resources[@role_id] = Resources::IAM.role
              policy = Policy.new policy: @policy
              policy.merge resources: resources
              security_group = SecurityGroup.new security_group: @security_group
              security_group.merge resources: resources
            end
          end
        end
      end
    end
  end
end
