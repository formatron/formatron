require 'spec_helper'
require 'formatron/dsl/formatron/vpc'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe VPC do
        extend DSLTest

        subnet_keys = %w(
          subnet1
          subnet2
          subnet3
        )

        dsl_before_hash do
          @external_subnets = subnet_keys.each_with_object({}) do |k, o|
            o[k] = instance_double(
              'Formatron::DSL::Formatron::Dependency::VPC::Subnet'
            )
          end
          @external = instance_double(
            'Formatron::DSL::Formatron::Dependency::VPC'
          )
          allow(@external).to receive(:subnets) { @external_subnets }
          { external: @external }
        end

        dsl_property :guid
        dsl_property :cidr
        dsl_hash :subnet, 'Subnet', subnet_keys do |key|
          { external: @external_subnets[key] }
        end

        describe '#external' do
          it 'should return the corresponding external VPC' do
            expect(@dsl_instance.external).to eql @external
          end
        end
      end
    end
  end
end
