require 'spec_helper'
require 'formatron/dsl/formatron'

class Formatron
  # namespacing for test
  class DSL
    describe Formatron do
      extend DSLTest

      dsl_before_block do
        @aws = instance_double 'Formatron::AWS'
        @external = instance_double 'Formatron::External'
        { external: @external, aws: @aws }
      end

      dsl_property :name
      dsl_property :bucket

      dsl_block :global, 'Global' do
        { aws: @aws }
      end

      dsl_hash :vpc, 'VPC'

      describe '#depends' do
        it 'should merge the dependency with the External object' do
          dependency = 'dependency'
          bucket = 'bucket'
          @dsl_instance.bucket bucket
          expect(@external).to receive(:merge).with(
            bucket: bucket,
            dependency: dependency
          )
          @dsl_instance.depends dependency
        end
      end
    end
  end
end
