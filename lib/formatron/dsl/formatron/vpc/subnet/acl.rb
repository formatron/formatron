require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # Subnet ACL configuration
          class ACL
            extend Util::DSL
            dsl_initialize_block
            dsl_array :source_cidr
          end
        end
      end
    end
  end
end
