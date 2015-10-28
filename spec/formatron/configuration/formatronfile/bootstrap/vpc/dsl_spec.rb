require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/vpc/dsl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # namespacing for tests
        class VPC
          describe DSL do
            block = proc do
              cidr "#{target}-#{config['cidr']}-#{name}-#{bucket}"

              config['subnets'].each do |key, value|
                subnet key do
                  "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                  "#{value}"
                end
              end
            end
            target = 'target'
            config = {
              'cidr' => 'cidr',
              'subnets' => {
                'subnet1' => 'subnet1',
                'subnet2' => 'subnet2',
                'subnet3' => 'subnet3'
              }
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

            describe '#cidr' do
              it 'should set the cidr property' do
                expect(@dsl.cidr).to eql(
                  "#{target}-#{config['cidr']}-#{name}-#{bucket}"
                )
              end
            end

            describe '#subnet' do
              it 'should set entries in the subnets property' do
                @dsl.subnets.each do |key, subnet|
                  expect(subnet.call).to eql(
                    "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                    "#{config['subnets'][key]}"
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
