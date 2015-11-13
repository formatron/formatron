require_relative 'formatron/global'
require_relative 'formatron/dependency'
require_relative 'formatron/vpc'
require 'formatron/util/dsl'

class Formatron
  class DSL
    # formatron top level DSL object
    class Formatron
      extend Util::DSL
      dsl_initialize_block do |aws:, external:|
        @aws = aws
        @external_vpcs = external.vpcs
      end
      dsl_property :name
      dsl_property :bucket
      dsl_block :global, 'Global'
      dsl_hash :dependency, 'Dependency' do |_key|
        { aws: @aws }
      end
      dsl_hash :vpc, 'VPC' do |key|
        { external: @external_vpcs[key] }
      end
    end
  end
end
