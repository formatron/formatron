require 'spec_helper'
require 'formatron/dsl/formatron'

class Formatron
  # namespacing for test
  class DSL
    describe Formatron do
      extend DSLTest
      dsl_before_block
      dsl_property :name
      dsl_property :bucket
      dsl_block :global, 'Global'
      dsl_hash :dependency, 'Dependency'
      dsl_hash :vpc, 'VPC'
    end
  end
end
