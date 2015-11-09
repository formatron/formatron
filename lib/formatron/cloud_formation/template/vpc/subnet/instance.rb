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
            INSTANCE_PROFILE_PREFIX = 'instanceProfile'

            def initialize(instance:)
              @instance = instance
              @guid = @instance.guid
              @role_id = "#{ROLE_PREFIX}#{@guid}"
              @instance_profile_id = "#{INSTANCE_PROFILE_PREFIX}#{@guid}"
              @policy = @instance.policy
              @security_group = @instance.security_group
            end

            def merge(resources:, outputs:)
              @outputs = outputs
              resources[@role_id] = Resources::IAM.role
              resources[@instance_profile_id] = Resources::IAM.instance_profile(
                role: @role_id
              )
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
