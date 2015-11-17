require 'formatron/util/dsl'
require_relative 'global/ec2'

class Formatron
  class DSL
    class Formatron
      # Global configuration
      class Global
        extend Util::DSL
        dsl_initialize_block
        dsl_property :protect
        dsl_property :kms_key
        dsl_property :databag_secret
        dsl_property :hosted_zone_id
        dsl_block :ec2, 'EC2'
      end
    end
  end
end
