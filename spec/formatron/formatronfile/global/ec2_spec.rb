require 'spec_helper'
require 'formatron/formatronfile/global/ec2'

class Formatron
  class Formatronfile
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
