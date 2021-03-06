require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance/security_group'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe SecurityGroup do
              extend DSLTest
              dsl_before_block
              dsl_array :open_tcp_port
              dsl_array :open_udp_port
            end
          end
        end
      end
    end
  end
end
