require 'spec_helper'
require 'formatron/dsl/formatron/vpc'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe VPC do
        extend DSLTest
        dsl_before_hash
        dsl_property :guid
        dsl_property :cidr
        dsl_hash :subnet, 'Subnet'
      end
    end
  end
end
