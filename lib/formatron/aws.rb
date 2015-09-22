require 'aws-sdk'

class Formatron
  # shared AWS clients
  class Aws
    attr_reader :s3_client, :cloudformation_client

    CREDENTIALS_JSON = 'credentials.json'

    def initialize(credentials_json)
      credentials = JSON.parse(File.read(credentials_json))
      region = credentials['region']
      aws_credentials = ::Aws::Credentials.new(
        credentials['accessKeyId'],
        credentials['secretAccessKey']
      )
      @s3_client = ::Aws::S3::Client.new(
        region: region,
        signature_version: 'v4',
        credentials: aws_credentials
      )
      @cloudformation_client = ::Aws::CloudFormation::Client.new(
        region: region,
        credentials: aws_credentials
      )
    end
  end
end
