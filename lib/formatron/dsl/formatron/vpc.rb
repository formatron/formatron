require_relative 'vpc/subnet'
require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      # VPC configuration
      class VPC
        extend Util::DSL

        attr_reader :external

        dsl_initialize_hash do |_key, external:|
          @external = external
          @external_subnets = @external.subnets
        end
        dsl_property :guid
        dsl_property :cidr
        dsl_hash :subnet, 'Subnet' do |key|
          { external: @external_subnets[key] }
        end
      end
    end
  end
end
