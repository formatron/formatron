require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/ec2/dsl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # namespacing for tests
        class EC2
          describe DSL do
            block = proc do
              key_pair "#{target}-#{config['key_pair']}-#{name}-#{bucket}"
              private_key(
                "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                "#{config['private_key']}"
              )
            end
            target = 'target'
            config = {
              'key_pair' => 'key_pair',
              'private_key' => 'private_key'
            }
            name = 'name'
            bucket = 'bucket'
            protect = 'protect'
            kms_key = 'kms_key'
            hosted_zone_id = 'hosted_zone_id'

            before(:each) do
              @dsl = DSL.new(
                {
                  target: target,
                  config: config,
                  name: name,
                  bucket: bucket,
                  protect: protect,
                  kms_key: kms_key,
                  hosted_zone_id: hosted_zone_id
                },
                block
              )
            end

            describe '#key_pair' do
              it 'should set the key_pair property' do
                expect(@dsl.key_pair).to eql(
                  "#{target}-#{config['key_pair']}-#{name}-#{bucket}"
                )
              end
            end

            describe '#private_key' do
              it 'should set the private_key property' do
                expect(@dsl.private_key).to eql(
                  "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                  "#{config['private_key']}"
                )
              end
            end
          end
        end
      end
    end
  end
end
