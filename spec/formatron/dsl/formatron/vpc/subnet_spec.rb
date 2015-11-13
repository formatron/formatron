require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet'

class Formatron
  class DSL
    class Formatron
      # namespacing for tests
      class VPC
        describe Subnet do
          extend DSLTest

          dsl_before_hash do
            @external = instance_double(
              'Formatron::DSL::Formatron::Dependency::VPC::Subnet'
            )
            { external: @external }
          end

          dsl_property :guid
          dsl_property :availability_zone
          dsl_property :cidr
          dsl_property :gateway
          dsl_block :acl, 'ACL'
          dsl_hash :nat, 'Instance'
          dsl_hash :bastion, 'Instance'
          dsl_hash :instance, 'Instance'
          dsl_hash :chef_server, 'ChefServer'

          describe '#external' do
            it 'should return the corresponding external subnet' do
              expect(@dsl_instance.external).to eql @external
            end
          end
        end
      end
    end
  end
end
