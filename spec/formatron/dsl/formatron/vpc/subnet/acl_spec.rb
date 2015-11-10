require 'formatron/dsl/formatron/vpc/subnet/acl'

class Formatron
  class DSL
    class Formatron
      class VPC
        # namespacing for tests
        class Subnet
          describe ACL do
            extend DSLTest
            dsl_before_block
            dsl_array :source_cidr
          end
        end
      end
    end
  end
end
