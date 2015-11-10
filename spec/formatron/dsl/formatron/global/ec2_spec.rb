require 'spec_helper'
require 'formatron/dsl/formatron/global/ec2'

class Formatron
  class DSL
    class Formatron
      # namespacing for tests
      class Global
        describe EC2 do
          extend DSLTest
          dsl_before_block
          dsl_property :key_pair
          dsl_property :private_key
        end
      end
    end
  end
end
