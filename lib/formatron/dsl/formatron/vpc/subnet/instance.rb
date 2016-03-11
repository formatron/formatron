require_relative 'instance/chef'
require_relative 'instance/policy'
require_relative 'instance/security_group'
require_relative 'instance/setup'
require_relative 'instance/volume'
require_relative 'instance/block_device'
require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class VPC
        class Subnet
          # Generic instance configuration
          class Instance
            extend Util::DSL
            dsl_initialize_hash
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
