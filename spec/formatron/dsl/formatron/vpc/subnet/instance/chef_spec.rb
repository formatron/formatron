require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance/chef'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe Chef do
              extend DSLTest
              dsl_before_block
              dsl_property :server
              dsl_property :cookbook
            end
          end
        end
      end
    end
  end
end
