require 'spec_helper'
require 'formatron/formatronfile'

# namespacing for test
class Formatron
  describe Formatronfile do
    extend DSLTest
    dsl_before_block
    dsl_property :name
    dsl_property :bucket
    dsl_block :global, 'Global'
    dsl_hash :dependency, 'Dependency'
    dsl_hash :vpc, 'VPC'
  end
end
