require 'spec_helper'
require 'formatron/s3_cloud_formation_template'

# namespacing for tests
class Formatron
  describe S3CloudFormationTemplate do
    target = 'target'
    name = 'name'
    kms_key = 'kms_key'
    bucket = 'bucket'
    cloud_formation_template = 'cloud_formation_template'
    key = 'key'
    url = 'url'
    region = 'region'

    before(:each) do
      @aws = instance_double 'Formatron::AWS'
      @s3_path = class_double(
        'Formatron::S3Path'
      ).as_stubbed_const
    end

    describe '::deploy' do
      it 'should upload the CloudFormation template to S3' do
        expect(@s3_path).to receive(:key).once.with(
          name: name,
          target: target,
          sub_key: 'cloud_formation_template.json'
        ) { key }
        expect(@aws).to receive(:upload_file).once.with(
          kms_key: kms_key,
          bucket: bucket,
          key: key,
          content: cloud_formation_template
        )
        S3CloudFormationTemplate.deploy(
          aws: @aws,
          kms_key: kms_key,
          bucket: bucket,
          name: name,
          target: target,
          cloud_formation_template: cloud_formation_template
        )
      end
    end

    describe '::destroy' do
      it 'should delete the CloudFormation template from S3' do
        expect(@s3_path).to receive(:key).once.with(
          name: name,
          target: target,
          sub_key: 'cloud_formation_template.json'
        ) { key }
        expect(@aws).to receive(:delete_file).once.with(
          bucket: bucket,
          key: key
        )
        S3CloudFormationTemplate.destroy(
          aws: @aws,
          bucket: bucket,
          name: name,
          target: target
        )
      end
    end

    describe '::url' do
      it 'should return the S3 url to the CloudFormation template' do
        expect(@s3_path).to receive(:url).once.with(
          region: region,
          bucket: bucket,
          name: name,
          target: target,
          sub_key: 'cloud_formation_template.json'
        ) { url }
        expect(
          S3CloudFormationTemplate.url(
            region: region,
            bucket: bucket,
            name: name,
            target: target
          )
        ).to eql url
      end
    end
  end
end
