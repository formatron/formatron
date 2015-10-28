require 'aws-sdk'

class Formatron
  # shared AWS clients
  class AWS
    attr_reader :s3_client, :cloudformation_client

    def initialize(credentials_json)
      credentials = JSON.parse(File.read(credentials_json))
      region = credentials['region']
      aws_credentials = _create_aws_credentials(credentials)
      _create_s3_client aws_credentials, region
      _create_cloudformation_client aws_credentials, region
    end

    def upload(kms_key, bucket, key, content)
      @s3_client.put_object(
        bucket: bucket,
        key: key,
        body: content,
        server_side_encryption: 'aws:kms',
        ssekms_key_id: kms_key
      )
    end

    def delete(bucket, key)
      @s3_client.delete_object(
        bucket: bucket,
        key: key
      )
    end

    def _create_aws_credentials(credentials)
      ::Aws::Credentials.new(
        credentials['access_key_id'],
        credentials['secret_access_key']
      )
    end

    def _create_s3_client(aws_credentials, region)
      @s3_client = ::Aws::S3::Client.new(
        region: region,
        signature_version: 'v4',
        credentials: aws_credentials
      )
    end

    def _create_cloudformation_client(aws_credentials, region)
      @cloudformation_client = ::Aws::CloudFormation::Client.new(
        region: region,
        credentials: aws_credentials
      )
    end

    private(
      :_create_aws_credentials,
      :_create_s3_client,
      :_create_cloudformation_client
    )
  end
end
