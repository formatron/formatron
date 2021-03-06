require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/instance'

class Formatron
  class DSL
    class Formatron
      class VPC
        # namespacing for tests
        class Subnet
          describe Instance do
            extend DSLTest
            dsl_before_hash
            dsl_property :guid
            dsl_property :sub_domain
            dsl_array :public_alias
            dsl_array :private_alias
            dsl_property :source_dest_check
            dsl_property :instance_type
            dsl_property :os
            dsl_property :ami
            dsl_block :chef, 'Chef'
            dsl_block :policy, 'Policy'
            dsl_block :security_group, 'SecurityGroup'
            dsl_block :setup, 'Setup'
            dsl_block_array :volume, 'Volume'
            dsl_block_array :block_device, 'BlockDevice'
          end
        end
      end
    end
  end
end
