require 'spec_helper'
require 'formatron/s3/cloud_formation_template'

class Formatron
  # namespacing for tests
  module S3
    describe CloudFormationTemplate do
      target = 'target'
      name = 'name'
      kms_key = 'kms_key'
      bucket = 'bucket'
      cloud_formation_template = 'cloud_formation_template'
      key = 'key'
      url = 'url'
      region = 'region'

      before(:each) do
        stub_const 'Formatron::LOG', Logger.new('/dev/null')
        @aws = instance_double 'Formatron::AWS'
        @s3_path = class_double(
          'Formatron::S3::Path'
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
          CloudFormationTemplate.deploy(
            aws: @aws,
            kms_key: kms_key,
            bucket: bucket,
            name: name,
            target: target,
            cloud_formation_template: cloud_formation_template
          )
        end
      end

      describe '::exists?' do
        it 'should return whether the CloudFormation template is on S3' do
          exists = 'exists'
          expect(@s3_path).to receive(:key).once.with(
            name: name,
            target: target,
            sub_key: 'cloud_formation_template.json'
          ) { key }
          expect(@aws).to receive(:file_exists?).once.with(
            bucket: bucket,
            key: key
          ) { exists }
          expect(
            CloudFormationTemplate.exists?(
              aws: @aws,
              bucket: bucket,
              name: name,
              target: target
            )
          ).to eql exists
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
          CloudFormationTemplate.destroy(
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
            CloudFormationTemplate.url(
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
end
