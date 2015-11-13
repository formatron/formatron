require 'formatron/util/dsl'
require_relative 'subnet/acl'
require_relative 'subnet/instance'
require_relative 'subnet/chef_server'

class Formatron
  class DSL
    class Formatron
      class VPC
        # Subnet configuration
        class Subnet
          extend Util::DSL

          attr_reader :external

          dsl_initialize_hash do |_key, external:|
            @external = external
          end

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
