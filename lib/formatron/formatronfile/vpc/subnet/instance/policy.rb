require 'formatron/util/dsl'
require_relative 'policy/statement'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          # IAM policy configuration
          class Policy
            extend Util::DSL
            dsl_initialize_block
            dsl_block_array :statement, 'Statement'
          end
        end
      end
    end
  end
end
