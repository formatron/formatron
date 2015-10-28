require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap'

class Formatron
  class Configuration
    # namespacing for tests
    class Formatronfile
      describe Bootstrap do
        target = 'target'
        config = {}
        name = 'name'
        bucket = 'bucket'
        block = proc do
          'bootstrap'
        end
        protect = true
        kms_key = 'kms_key'
        hosted_zone_id = 'hosted_zone_id'
        ec2_block = proc do
          'ec2'
        end

        before(:each) do
          @dsl_class = class_double(
            'Formatron::Configuration::Formatronfile::Bootstrap::DSL'
          ).as_stubbed_const
          @dsl = instance_double(
            'Formatron::Configuration::Formatronfile::Bootstrap::DSL'
          )
          expect(@dsl_class).to receive(:new).once.with(
            target,
            config,
            name,
            bucket,
            block
          ) { @dsl }

          allow(@dsl).to receive(:protect) { protect }
          allow(@dsl).to receive(:kms_key) { kms_key }
          allow(@dsl).to receive(:hosted_zone_id) { hosted_zone_id }
          allow(@dsl).to receive(:ec2) { ec2_block }

          @ec2_class = class_double(
            'Formatron::Configuration::Formatronfile::Bootstrap::EC2'
          ).as_stubbed_const
          @ec2 = instance_double(
            'Formatron::Configuration::Formatronfile::Bootstrap::EC2'
          )
          expect(@ec2_class).to receive(:new).once.with(
            target,
            config,
            name,
            bucket,
            kms_key,
            protect,
            hosted_zone_id,
            block
          ) { @ec2 }

          @bootstrap = Bootstrap.new(
            target,
            config,
            name,
            bucket,
            block
          )
        end

        describe '#protect' do
          it 'should return whether the configuration should be ' \
             'protected from accidental deployment, etc' do
            expect(@bootstrap.protect).to eql protect
          end
        end

        describe '#kms_key' do
          it 'should return the KMS key' do
            expect(@bootstrap.kms_key).to eql kms_key
          end
        end

        describe '#hosted_zone_id' do
          it 'should return the Route53 public hosted zone ID' do
            expect(@bootstrap.hosted_zone_id).to eql hosted_zone_id
          end
        end

        describe '#ec2' do
          it 'should return the EC2 configuration' do
            expect(@bootstrap.ec2).to eql @ec2
          end
        end
      end
    end
  end
end
