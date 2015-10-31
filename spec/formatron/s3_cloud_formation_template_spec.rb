require 'spec_helper'
require 'formatron/s3_cloud_formation_template'

# namespacing for tests
class Formatron
  describe S3CloudFormationTemplate do
    target = 'target'
    kms_key = 'kms_key'
    bucket = 'bucket'
    cloud_formation_template = 'cloud_formation_template'
    key = 'key'

    before(:each) do
      @aws = instance_double 'Formatron::AWS'
      @configuration = instance_double 'Formatron::Configuration'
      @s3_path = class_double(
        'Formatron::S3Path'
      ).as_stubbed_const
    end

    describe '::deploy' do
      it 'should upload the CloudFormation template to S3' do
        expect(@s3_path).to receive(:path).once.with(
          configuration: @configuration,
          target: target,
          sub_path: 'cloud_formation_template.json'
        ) { key }
        expect(@configuration).to receive(:kms_key).once.with(
          target
        ) { kms_key }
        expect(@configuration).to receive(:bucket).once.with(
          target
        ) { bucket }
        expect(@configuration).to receive(:cloud_formation_template).once.with(
          target
        ) { cloud_formation_template }
        expect(@aws).to receive(:upload_file).once.with(
          kms_key,
          bucket,
          key,
          cloud_formation_template
        )
        S3CloudFormationTemplate.deploy(
          aws: @aws,
          configuration: @configuration,
          target: target
        )
      end
    end

    describe '::destroy' do
      it 'should delete the CloudFormation template from S3' do
        expect(@s3_path).to receive(:path).once.with(
          configuration: @configuration,
          target: target,
          sub_path: 'cloud_formation_template.json'
        ) { key }
        expect(@configuration).to receive(:bucket).once.with(
          target
        ) { bucket }
        expect(@aws).to receive(:delete_file).once.with(
          bucket,
          key
        )
        S3CloudFormationTemplate.destroy(
          aws: @aws,
          configuration: @configuration,
          target: target
        )
      end
    end
  end
end
