require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance/policy'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe Policy do
              extend DSLTest
              dsl_before_block
              dsl_block_array :statement, 'Statement'
            end
          end
        end
      end
    end
  end
end
