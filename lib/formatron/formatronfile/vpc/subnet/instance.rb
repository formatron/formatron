require_relative 'instance/chef'
require_relative 'instance/policy'
require_relative 'instance/security_group'
require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        # Generic instance configuration
        class Instance
          extend Util::DSL
          dsl_initialize_hash
          dsl_property :guid
          dsl_property :subnet
          dsl_block :chef, 'Chef'
          dsl_block :policy, 'Policy'
          dsl_block :security_group, 'SecurityGroup'
        end
      end
    end
  end
end
