require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet/instance/setup/variable'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          # namespacing for tests
          class Setup
            describe Variable do
              extend DSLTest
              dsl_before_hash
              dsl_property :value
            end
          end
        end
      end
    end
  end
end
