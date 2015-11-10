require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          class Instance
            # Generic instance configuration
            class Chef
              extend Util::DSL
              dsl_initialize_block
              dsl_property :server
              dsl_property :cookbook
            end
          end
        end
      end
    end
  end
end
