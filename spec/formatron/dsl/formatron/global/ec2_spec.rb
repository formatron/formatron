require 'spec_helper'
require 'formatron/dsl/formatron/global/ec2'

class Formatron
  class DSL
    class Formatron
      # namespacing for tests
      class Global
        describe EC2 do
          extend DSLTest

          dsl_before_block do
            @external = instance_double 'Formatron::External::Global::EC2'
            { external: @external }
          end

          dsl_property :key_pair
          dsl_property :private_key

          describe '#external' do
            it 'should return the corresponding external EC2' do
              expect(@dsl_instance.external).to eql @external
            end
          end
        end
      end
    end
  end
end
