require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance/block_device'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe BlockDevice do
              extend DSLTest
              dsl_before_block
              dsl_property :device
              dsl_property :size
              dsl_property :type
              dsl_property :iops
            end
          end
        end
      end
    end
  end
end
