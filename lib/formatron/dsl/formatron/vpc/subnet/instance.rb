require_relative 'instance/chef'
require_relative 'instance/policy'
require_relative 'instance/security_group'
require_relative 'instance/setup'
require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # Generic instance configuration
          class Instance
            extend Util::DSL
            dsl_initialize_hash
            dsl_property :guid
            dsl_property :sub_domain
            dsl_property :source_dest_check
            dsl_property :instance_type
            dsl_block :chef, 'Chef'
            dsl_block :policy, 'Policy'
            dsl_block :security_group, 'SecurityGroup'
            dsl_block :setup, 'Setup'
          end
        end
      end
    end
  end
end
