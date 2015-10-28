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
      end
    end
  end
end
