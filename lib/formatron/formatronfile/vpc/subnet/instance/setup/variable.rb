require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          # Instance setup scripts
          class Setup
            # Instance setup variables
            class Variable
              extend Util::DSL
              dsl_initialize_hash
              dsl_property :value
            end
          end
        end
      end
    end
  end
end
