require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      # Global configuration
      class Global
        extend Util::DSL
        dsl_initialize_block
        dsl_property :protect
        dsl_property :kms_key
        dsl_property :hosted_zone_id
        dsl_block :ec2, 'EC2'
      end
    end
  end
end
