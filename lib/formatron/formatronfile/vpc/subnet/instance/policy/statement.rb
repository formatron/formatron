require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          class Policy
            # IAM policy statement configuration
            class Statement
              extend Util::DSL
              dsl_initialize_block
              dsl_array :action
              dsl_array :resource
            end
          end
        end
      end
    end
  end
end
