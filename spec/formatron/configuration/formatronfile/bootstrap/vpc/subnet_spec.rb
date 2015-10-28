require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/vpc/subnet'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # namespacing for tests
        class VPC
          describe Subnet do
            target = 'target'
            config = {}
            name = 'name'
            bucket = 'bucket'
            protect = true
            kms_key = 'kms_key'
            hosted_zone_id = 'hosted_zone_id'
            cidr = 'cidr'
            subnet_name = 'subnet_name'
            block = proc do
              'subnet'
            end
            availability_zone = 'availability_zone'
            subnet_cidr = 'subnet_cidr'
            make_public = 'make_public'

            before(:each) do
              @dsl_class = class_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet::DSL'
              ).as_stubbed_const
              @dsl = instance_double(
                'Formatron::Configuration::Formatronfile' \
                '::Bootstrap::VPC::Subnet::DSL'
              )
              expect(@dsl_class).to receive(:new).once.with(
                {
                  target: target,
                  config: config,
                  name: name,
                  bucket: bucket,
                  protect: protect,
                  kms_key: kms_key,
                  hosted_zone_id: hosted_zone_id,
                  cidr: cidr,
                  subnet_name: subnet_name
                },
                block
              ) { @dsl }

              allow(@dsl).to receive(:availability_zone) { availability_zone }
              allow(@dsl).to receive(:cidr) { subnet_cidr }
              allow(@dsl).to receive(:source_ips) { make_public }

              @subnet = Subnet.new(
                {
                  target: target,
                  config: config,
                  name: name,
                  bucket: bucket,
                  protect: protect,
                  kms_key: kms_key,
                  hosted_zone_id: hosted_zone_id,
                  cidr: cidr,
                  subnet_name: subnet_name
                },
                block
              )
            end

            describe '#availability_zone' do
              it 'should return the availability zone' do
                expect(@subnet.availability_zone).to eql availability_zone
              end
            end

            describe '#cidr' do
              it 'should return the subnet cidr' do
                expect(@subnet.cidr).to eql subnet_cidr
              end
            end

            describe '#source_ips' do
              it 'should return the source IPs' do
                expect(@subnet.source_ips).to eql make_public
              end
            end
          end
        end
      end
    end
  end
end
