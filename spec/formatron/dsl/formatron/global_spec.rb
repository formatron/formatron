require 'spec_helper'
require 'formatron/dsl/formatron/global'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe Global do
        extend DSLTest

        dsl_before_block do
          @hosted_zone_id = 'hosted_zone_id'
          @hosted_zone_name = 'hosted_zone_name'
          @aws = instance_double 'Formatron::AWS'
          allow(@aws).to receive(:hosted_zone_name).with(
            @hosted_zone_id
          ) { @hosted_zone_name }
          { aws: @aws }
        end

        dsl_property :protect
        dsl_property :kms_key
        dsl_property :databag_secret
        dsl_block :ec2, 'EC2'

        describe '#hosted_zone_id' do
          before :each do
            @dsl_instance.hosted_zone_id @hosted_zone_id
          end

          it 'should set the hosted_zone_id field' do
            expect(@dsl_instance.hosted_zone_id).to eql @hosted_zone_id
          end

          it 'should set the hosted_zone_name field' do
            expect(@dsl_instance.hosted_zone_name).to eql @hosted_zone_name
          end
        end
      end
    end
  end
end
