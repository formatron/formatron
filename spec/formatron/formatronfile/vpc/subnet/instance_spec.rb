require 'spec_helper'
require 'formatron/formatronfile/vpc/subnet/instance'

class Formatron
  class Formatronfile
    class VPC
      # namespacing for tests
      class Subnet
        describe Instance do
          extend DSLTest
          dsl_before_hash
          dsl_property :guid
          dsl_property :sub_domain
          dsl_property :source_dest_check
          dsl_property :instance_type
          dsl_block :chef, 'Chef'
          dsl_block :policy, 'Policy'
          dsl_block :security_group, 'SecurityGroup'
          dsl_block :setup, 'Setup'
        end
      end
    end
  end
end
