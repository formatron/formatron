require 'spec_helper'
require 'formatron/aws'

describe Formatron::AWS do
  region = 'region'
  access_key_id = 'access_key_id'
  secret_access_key = 'secret_access_key'

  before(:each) do
    aws_credentials = instance_double('Aws::Credentials')
    aws_credentials_class = class_double('Aws::Credentials').as_stubbed_const
    expect(aws_credentials_class).to receive(:new).with(
      access_key_id,
      secret_access_key
    ).once { aws_credentials }
    @s3_client = instance_double('Aws::S3::Client')
    s3_client_class = class_double('Aws::S3::Client').as_stubbed_const
    expect(s3_client_class).to receive(:new).with(
      region: region,
      signature_version: 'v4',
      credentials: aws_credentials
    ).once { @s3_client }
    @cloudformation_client = instance_double('Aws::CloudFormation::Client')
    cloudformation_client_class = class_double(
      'Aws::CloudFormation::Client'
    ).as_stubbed_const
    expect(cloudformation_client_class).to receive(:new).with(
      region: region,
      credentials: aws_credentials
    ).once { @cloudformation_client }
  end

  context 'with credentials' do
    include FakeFS::SpecHelpers

    before(:each) do
      Dir.mkdir('test')
      File.write(
        File.join('test', 'credentials.json'),
        <<-EOH.gsub(/^\s{8}/, '')
          {
            "region": "#{region}",
            "access_key_id": "#{access_key_id}",
            "secret_access_key": "#{secret_access_key}"
          }
        EOH
      )
      @aws = Formatron::AWS.new(
        File.join('test', 'credentials.json')
      )
    end

    describe '#upload' do
      content = 'content'
      bucket = 'bucket'
      key = 'key'
      kms_key = 'kms_key'

      it 'should encrypt and upload the given content to S3' do
        expect(@s3_client).to receive(:put_object).once.with(
          bucket: bucket,
          key: key,
          body: content,
          server_side_encryption: 'aws:kms',
          ssekms_key_id: kms_key
        )
        @aws.upload(
          kms_key,
          bucket,
          key,
          content
        )
      end
    end

    describe '#delete' do
      bucket = 'bucket'
      key = 'key'

      it 'should recursively delete the key from the bucket' do
        expect(@s3_client).to receive(:delete_object).once.with(
          bucket: bucket,
          key: key
        )
        @aws.delete(
          bucket,
          key
        )
      end
    end
  end
end
