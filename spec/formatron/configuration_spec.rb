require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration'

# namespacing for tests
class Formatron
  describe Configuration do
    directory = 'test/configuration'
    targets = %w(target1 target2)
    target_config = {
      param: 'param'
    }
    cloud_formation_template = 'cloud_formation_template'
    protect = true
    name = 'name'
    kms_key = 'kms_key'
    bucket = 'bucket'

    before(:each) do
      @config = class_double(
        'Formatron::Configuration::Config'
      ).as_stubbed_const
      allow(@config).to receive(:targets) { targets }
      allow(@config).to receive(:target) { target_config }

      @formatronfile_class = class_double(
        'Formatron::Configuration::Formatronfile'
      ).as_stubbed_const
      @formatronfile = instance_double(
        'Formatron::Configuration::Formatronfile'
      )
      allow(@formatronfile_class).to receive(:new) { @formatronfile }
      allow(@formatronfile).to receive(:name) { name }
      allow(@formatronfile).to receive(:bucket) { bucket }
      allow(@formatronfile).to receive(:protected?) { protect }
      allow(@formatronfile).to receive(:kms_key) { kms_key }

      @cloud_formation = class_double(
        'Formatron::Configuration::CloudFormation'
      ).as_stubbed_const
      allow(@cloud_formation).to receive(:template) { cloud_formation_template }

      @aws = instance_double('Formatron::AWS')

      @configuration = Configuration.new(@aws, directory)
    end

    describe '#targets' do
      it 'should return the targets defined in the config directory' do
        expect(@configuration.targets).to eql targets
        expect(@config).to have_received(:targets).once.with directory
      end
    end

    describe '#protected?' do
      it 'should check the Formatronfile to see if ' \
         'the target should be protected' do
        expect(@configuration.protected?(targets[0])).to eql protect
        expect(@config).to have_received(:target).once.with(
          directory: directory,
          target: targets[0]
        )
        expect(@formatronfile_class).to have_received(:new).once.with(
          aws: @aws,
          target: targets[0],
          config: target_config,
          directory: directory
        )
        expect(@formatronfile).to have_received(:protected?).once.with no_args
      end
    end

    describe '#name' do
      it 'should return the name from the Formatronfile' do
        expect(@configuration.name(targets[0])).to eql name
        expect(@formatronfile).to have_received(:name).once.with no_args
      end
    end

    describe '#kms_key' do
      it 'should return the KMS key from the Formatronfile' do
        expect(@configuration.kms_key(targets[0])).to eql kms_key
        expect(@formatronfile).to have_received(:kms_key).once.with no_args
      end
    end

    describe '#bucket' do
      it 'should return the bucket from the Formatronfile' do
        expect(@configuration.bucket(targets[0])).to eql bucket
        expect(@formatronfile).to have_received(:bucket).once.with no_args
      end
    end

    describe '#config' do
      it 'should return the merged config to be uploaded to S3' do
        expect(@configuration.config(targets[0])).to eql target_config
      end
    end

    describe '#cloud_formation_template' do
      it 'should return the CloudFormation template to be uploaded to S3' do
        expect(@configuration.cloud_formation_template(targets[0])).to eql(
          cloud_formation_template
        )
        expect(@cloud_formation).to have_received(
          :template
        ).once.with(
          @formatronfile
        )
      end
    end
  end
end
