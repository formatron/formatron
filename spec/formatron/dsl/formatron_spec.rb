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
        @external = instance_double 'Formatron::External'
        @external_vpcs = vpc_keys.each_with_object({}) do |k, o|
          o[k] = instance_double(
            'Formatron::External::VPC'
          )
        end
        allow(@external).to receive(:vpcs) { @external_vpcs }
        @external_global = instance_double 'Formatron::External::Global'
        allow(@external).to receive(:global) { @external_global }
        { external: @external }
      end

      dsl_property :name
      dsl_property :bucket
      dsl_block :global, 'Global' do
        { external: @external_global }
      end
      dsl_hash :vpc, 'VPC', vpc_keys do |key|
        { external: @external_vpcs[key] }
      end

      describe '#depends' do
        it 'should merge the dependency with the External object' do
          dependency = 'dependency'
          expect(@external).to receive(:merge).with(
            dependency: dependency
          )
          @dsl_instance.depends dependency
        end
      end
    end
  end
end
