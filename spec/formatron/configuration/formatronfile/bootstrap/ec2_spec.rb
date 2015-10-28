require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/ec2'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe EC2 do
          target = 'target'
          config = {}
          name = 'name'
          bucket = 'bucket'
          protect = true
          kms_key = 'kms_key'
          hosted_zone_id = 'hosted_zone_id'
          block = proc do
            'ec2'
          end
          key_pair = 'key_pair'
          private_key = 'private_key'

          before(:each) do
            @dsl_class = class_double(
              'Formatron::Configuration::Formatronfile::Bootstrap::EC2::DSL'
            ).as_stubbed_const
            @dsl = instance_double(
              'Formatron::Configuration::Formatronfile::Bootstrap::EC2::DSL'
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

            allow(@dsl).to receive(:key_pair) { key_pair }
            allow(@dsl).to receive(:private_key) { private_key }

            @ec2 = EC2.new(
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
            it 'should return the EC2 key pair name' do
              expect(@ec2.key_pair).to eql key_pair
            end
          end

          describe '#private_key' do
            it 'should return the KMS key' do
              expect(@ec2.private_key).to eql private_key
            end
          end
        end
      end
    end
  end
end
