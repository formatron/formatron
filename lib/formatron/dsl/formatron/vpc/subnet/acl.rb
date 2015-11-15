require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # Subnet ACL configuration
          class ACL
            extend Util::DSL

            attr_reader :external

            dsl_initialize_block do |external:|
              @external = external
            end

            dsl_array :source_cidr
          end
        end
      end
    end
  end
end
