require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet/instance/policy/statement'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          # namespacing for tests
          class Policy
            describe Statement do
              extend DSLTest
              dsl_before_block
              dsl_array :action
              dsl_array :resource
            end
          end
        end
      end
    end
  end
end
