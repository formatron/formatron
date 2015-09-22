require 'spec_helper'
require 'formatron/aws'

describe Formatron::Aws do
  before(:each) do
    aws_credentials = instance_double('Aws::Credentials')
    aws_credentials_class = class_double('Aws::Credentials').as_stubbed_const
    expect(aws_credentials_class).to receive(:new).with(
      'access_key_id',
      'secret_access_key'
    ).once { aws_credentials }
    @s3_client = instance_double('Aws::S3::Client')
    s3_client_class = class_double('Aws::S3::Client').as_stubbed_const
    expect(s3_client_class).to receive(:new).with(
      region: 'region',
      signature_version: 'v4',
      credentials: aws_credentials
    ).once { @s3_client }
    @cloudformation_client = instance_double('Aws::CloudFormation::Client')
    cloudformation_client_class = class_double(
      'Aws::CloudFormation::Client'
    ).as_stubbed_const
    expect(cloudformation_client_class).to receive(:new).with(
      region: 'region',
      credentials: aws_credentials
    ).once { @cloudformation_client }
  end

  context 'with a valid credentials json file' do
    include FakeFS::SpecHelpers

    before(:each) do
      Dir.mkdir('test')
      File.write(
        File.join('test', 'credentials.json'),
        <<-EOH.gsub(/^\s{8}/, '')
          {
            "region": "region",
            "accessKeyId": "access_key_id",
            "secretAccessKey": "secret_access_key"
          }
        EOH
      )
    end

    it 'should initialize the S3 and CloudFormation clients' do
      aws = Formatron::Aws.new(
        File.join('test', 'credentials.json')
      )
      expect(aws.s3_client).to equal(@s3_client)
      expect(aws.cloudformation_client).to equal(@cloudformation_client)
    end
  end
end
