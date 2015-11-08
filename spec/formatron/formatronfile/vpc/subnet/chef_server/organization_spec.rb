require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet' \
        '/chef_server/organization'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        # namespacing for tests
        class ChefServer
          describe Organization do
            extend DSLTest
            dsl_before_block
            dsl_property :short_name
            dsl_property :full_name
          end
        end
      end
    end
  end
end
