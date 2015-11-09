require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        class Instance
          # Instance security group configuration
          class SecurityGroup
            extend Util::DSL
            dsl_initialize_block
            dsl_array :open_tcp_port
            dsl_array :open_udp_port
          end
        end
      end
    end
  end
end
