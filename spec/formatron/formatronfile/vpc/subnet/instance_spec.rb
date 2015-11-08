require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet/instance'

class Formatron
  class Formatronfile
    class VPC
      # namespacing for tests
      class Subnet
        describe Instance do
          extend DSLTest
          dsl_before_hash
          dsl_property :guid
          dsl_property :subnet
          dsl_block :chef, 'Chef'
        end
      end
    end
  end
end
