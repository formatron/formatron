require_relative 'formatron/global'
require_relative 'formatron/vpc'
require 'formatron/util/dsl'

class Formatron
  class DSL
    # formatron top level DSL object
    class Formatron
      extend Util::DSL

      dsl_initialize_block do |external:|
        @external = external
      end

      dsl_property :name
      dsl_property :bucket
      dsl_block :global, 'Global'
      dsl_hash :vpc, 'VPC'

      def depends(dependency)
        @external.merge bucket: @bucket, dependency: dependency
      end
    end
  end
end
