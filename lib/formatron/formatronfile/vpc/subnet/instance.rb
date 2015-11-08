require_relative 'instance/chef'
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
        end
      end
    end
  end
end
