require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet'

class Formatron
  class Formatronfile
    # namespacing for tests
    class VPC
      describe Subnet do
        extend DSLTest
        dsl_before_hash
        dsl_property :guid
        dsl_property :availability_zone
        dsl_property :cidr
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
