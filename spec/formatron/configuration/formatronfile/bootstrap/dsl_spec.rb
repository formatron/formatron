require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/dsl'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe DSL do
          block = proc do
            protect true
            kms_key "#{target}-#{config['kms_key']}-#{name}-#{bucket}"
            hosted_zone_id "#{config['hosted_zone_id']}"
            ec2 do
              'ec2'
            end
          end
          target = 'target'
          config = {
            'kms_key' => 'kms_key',
            'hosted_zone_id' => 'hosted_zone_id'
          }
          name = 'name'
          bucket = 'bucket'

          before(:each) do
            @dsl = DSL.new(
              {
                target: target,
                config: config,
                name: name,
                bucket: bucket
              },
              block
            )
          end

          describe '#protect' do
            it 'should set the protect property' do
              expect(@dsl.protect).to eql true
            end
          end

          describe '#kms_key' do
            it 'should set the kms_key property' do
              expect(@dsl.kms_key).to eql(
                "#{target}-#{config['kms_key']}-#{name}-#{bucket}"
              )
            end
          end

          describe '#hosted_zone_id' do
            it 'should set the hosted_zone_id property' do
              expect(@dsl.hosted_zone_id).to eql(
                "#{config['hosted_zone_id']}"
              )
            end
          end

          describe '#ec2' do
            it 'should set the ec2 property' do
              expect(@dsl.ec2.call).to eql(
                'ec2'
              )
            end
          end
        end
      end
    end
  end
end
