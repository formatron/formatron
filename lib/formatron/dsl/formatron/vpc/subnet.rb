require_relative 'subnet/acl'
require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        # Subnet configuration
        class Subnet
          extend Util::DSL
          dsl_initialize_hash
          dsl_property :guid
          dsl_property :cidr
          dsl_property :availability_zone
          dsl_property :gateway
          dsl_block :acl, 'ACL'
          dsl_hash :nat, 'Instance'
          dsl_hash :bastion, 'Instance'
          dsl_hash :instance, 'Instance'
          dsl_hash :chef_server, 'ChefServer'
        end
      end
    end
  end
end
