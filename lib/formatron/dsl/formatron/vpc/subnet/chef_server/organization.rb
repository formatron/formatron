require_relative '../instance'
require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          class ChefServer < Instance
            #  Chef Server organization configuration
            class Organization
              extend Util::DSL
              dsl_initialize_block
              dsl_property :short_name
              dsl_property :full_name
            end
          end
        end
      end
    end
  end
end
