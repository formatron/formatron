require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet/instance/setup'

class Formatron
  class Formatronfile
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
