require_relative 'formatronfile/global'
require_relative 'formatronfile/dependency'
require_relative 'formatronfile/vpc'
require 'formatron/util/dsl'

class Formatron
  # DSL for the Formatronfile
  class Formatronfile
    extend Util::DSL
    dsl_initialize_block
    dsl_property :name
    dsl_property :bucket
    dsl_block :global, 'Global'
    dsl_hash :dependency, 'Dependency'
    dsl_hash :vpc, 'VPC'
  end
end
