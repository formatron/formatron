require 'formatron/util/dsl'
require_relative 'setup/variable'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          class Instance
            # Instance setup scripts
            class Setup
              extend Util::DSL
              dsl_initialize_block
              dsl_hash :variable, 'Variable'
              dsl_array :script
            end
          end
        end
      end
    end
  end
end
