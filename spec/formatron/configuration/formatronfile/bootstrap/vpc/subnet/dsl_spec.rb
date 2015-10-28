require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/vpc/subnet/dsl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          # namespacing for tests
          class Subnet
            describe DSL do
              block = proc do
                availability_zone(
                  "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                  "#{config['availability_zone']}"
                )
                cidr "#{target}-#{config['cidr']}-#{name}-#{bucket}"
                make_public ["#{vpc_cidr}-#{subnet_name}"]
              end
              target = 'target'
              config = {
                'availability_zone' => 'availability_zone',
                'cidr' => 'subnet_cidr'
              }
              name = 'name'
              bucket = 'bucket'
              protect = 'protect'
              kms_key = 'kms_key'
              hosted_zone_id = 'hosted_zone_id'
              cidr = 'cidr'
              subnet_name = 'subnet_name'

              before(:each) do
                @dsl = DSL.new(
                  {
                    target: target,
                    config: config,
                    name: name,
                    bucket: bucket,
                    protect: protect,
                    kms_key: kms_key,
                    hosted_zone_id: hosted_zone_id,
                    vpc_cidr: cidr,
                    subnet_name: subnet_name
                  },
                  block
                )
              end

              describe '#availability_zone' do
                it 'should set the availability_zone property' do
                  expect(@dsl.availability_zone).to eql(
                    "#{protect}-#{kms_key}-#{hosted_zone_id}-" \
                    "#{config['availability_zone']}"
                  )
                end
              end

              describe '#cidr' do
                it 'should set the cidr property' do
                  expect(@dsl.cidr).to eql(
                    "#{target}-#{config['cidr']}-#{name}-#{bucket}"
                  )
                end
              end

              describe '#make_public' do
                it 'should set the source_ips property' do
                  expect(@dsl.source_ips).to eql(
                    ["#{cidr}-#{subnet_name}"]
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
