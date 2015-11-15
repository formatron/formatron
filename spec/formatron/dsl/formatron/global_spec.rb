require 'spec_helper'
require 'formatron/dsl/formatron/global'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe Global do
        extend DSLTest

        dsl_before_block do
          @external = instance_double 'Formatron::External::Global'
          @external_ec2 = instance_double(
            'Formatron::External::Global::EC2'
          )
          allow(@external).to receive(:ec2) { @external_ec2 }
          { external: @external }
        end

        dsl_property :protect
        dsl_property :kms_key
        dsl_property :hosted_zone_id
        dsl_block :ec2, 'EC2' do
          { external: @external_ec2 }
        end

        describe '#external' do
          it 'should return the corresponding external Global' do
            expect(@dsl_instance.external).to eql @external
          end
        end
      end
    end
  end
end
