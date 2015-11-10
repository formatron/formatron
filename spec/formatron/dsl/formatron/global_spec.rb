require 'spec_helper'
require 'formatron/dsl/formatron/global'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe Global do
        extend DSLTest
        dsl_before_block
        dsl_property :protect
        dsl_property :kms_key
        dsl_property :hosted_zone_id
        dsl_block :ec2, 'EC2'
      end
    end
  end
end
