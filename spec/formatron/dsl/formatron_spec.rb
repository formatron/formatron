require 'spec_helper'
require 'formatron/dsl/formatron'

class Formatron
  # namespacing for test
  class DSL
    describe Formatron do
      extend DSLTest

      vpc_keys = %w(
        vpc1
        vpc2
        vpc3
      )

      dsl_before_block do
        @aws = instance_double 'Formatron::AWS'
        external = instance_double 'Formatron::External'
        @external_vpcs = vpc_keys.each_with_object({}) do |k, o|
          o[k] = instance_double(
            'Formatron::DSL::Formatron::Dependency::VPC'
          )
        end
        allow(external).to receive(:vpcs) { @external_vpcs }
        { aws: @aws, external: external }
      end

      dsl_property :name
      dsl_property :bucket
      dsl_block :global, 'Global'
      dsl_hash :dependency, 'Dependency' do |_key|
        { aws: @aws }
      end
      dsl_hash :vpc, 'VPC', vpc_keys do |key|
        { external: @external_vpcs[key] }
      end
    end
  end
end
