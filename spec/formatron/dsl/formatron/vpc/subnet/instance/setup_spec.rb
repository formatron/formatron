require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance/setup'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe Setup do
              extend DSLTest
              dsl_before_block
              dsl_hash :variable, 'Variable'
              dsl_array :script
            end
          end
        end
      end
    end
  end
end
