require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/vpc'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe VPC do
          target = 'target'
          config = {}
          name = 'name'
          bucket = 'bucket'
          protect = true
          kms_key = 'kms_key'
          hosted_zone_id = 'hosted_zone_id'
          block = proc do
            'vpc'
          end
          cidr = 'cidr'
          subnets = {
            'subnet1' => proc do
              'subnet1'
            end,
            'subnet2' => proc do
              'subnet2'
            end
          }

          before(:each) do
            @dsl_class = class_double(
              'Formatron::Configuration::Formatronfile::Bootstrap::VPC::DSL'
            ).as_stubbed_const
            @dsl = instance_double(
              'Formatron::Configuration::Formatronfile::Bootstrap::VPC::DSL'
            )
            expect(@dsl_class).to receive(:new).once.with(
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
            ) { @dsl }

            allow(@dsl).to receive(:cidr) { cidr }
            allow(@dsl).to receive(:subnets) { subnets }

            subnet_class = class_double(
              'Formatron::Configuration::Formatronfile::Bootstrap::VPC::Subnet'
            ).as_stubbed_const
            @subnets = {}
            subnets.each do |key, _|
              @subnets[key] = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet'
              )
            end
            subnets.each do |key, subnet|
              expect(subnet_class).to receive(:new).once.with(
                {
                  target: target,
                  config: config,
                  name: name,
                  bucket: bucket,
                  protect: protect,
                  kms_key: kms_key,
                  hosted_zone_id: hosted_zone_id,
                  vpc_cidr: cidr,
                  subnet_name: key
                },
                subnet
              ) { @subnets[key] }
            end

            @vpc = VPC.new(
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
            it 'should return the VPC CIDR' do
              expect(@vpc.cidr).to eql cidr
            end
          end

          describe '#subnets' do
            it 'should return the subnet configurations' do
              expect(@vpc.subnets).to eql @subnets
            end
          end
        end
      end
    end
  end
end
