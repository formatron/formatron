require 'spec_helper'
require 'formatron/formatronfile/vpc'

class Formatron
  # namespacing for tests
  class Formatronfile
    describe VPC do
      extend DSLTest
      dsl_before_hash
      dsl_property :guid
      dsl_property :cidr
      dsl_hash :subnet, 'Subnet'
    end
  end
end
