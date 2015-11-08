require_relative 'vpc/subnet'
require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    # VPC configuration
    class VPC
      extend Util::DSL
      dsl_initialize_hash
      dsl_property :guid
      dsl_property :cidr
      dsl_hash :subnet, 'Subnet'
    end
  end
end
