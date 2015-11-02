require 'aws-sdk'

class Formatron
  # shared AWS clients
  # rubocop:disable Metrics/ClassLength
  class AWS
    attr_reader :region

    REGIONS = {
      'us-east-1' => {
        ami: 'ami-ff02509a'
      },
      'us-west-2' => {
        ami: 'ami-8ee605bd'
      },
      'us-west-1' => {
        ami: 'ami-198a495d'
      },
      'eu-west-1' => {
        ami: 'ami-37360a40'
      },
      'eu-central-1' => {
        ami: 'ami-46272b5b'
      },
      'ap-southeast-1' => {
        ami: 'ami-42170410'
      },
      'ap-southeast-2' => {
        ami: 'ami-6d6c2657'
      },
      'ap-northeast-1' => {
        ami: 'ami-402e4c40'
      },
      'sa-east-1' => {
        ami: 'ami-1f4bda02'
      }
    }

    CAPABILITIES = ['CAPABILITY_IAM']

    def initialize(credentials_json)
      @credentials = JSON.parse(File.read(credentials_json))
      @region = @credentials['region']
      _create_aws_credentials
      _create_s3_client
      _create_cloudformation_client
      _create_route53_client
    end

    def upload_file(kms_key:, bucket:, key:, content:)
      @s3_client.put_object(
        bucket: bucket,
        key: key,
        body: content,
        server_side_encryption: 'aws:kms',
        ssekms_key_id: kms_key
      )
    end

    def delete_file(bucket:, key:)
      @s3_client.delete_object(
        bucket: bucket,
        key: key
      )
    end

    def deploy_stack(stack_name:, template_url:)
      @cloudformation_client.create_stack(
        stack_name: stack_name,
        template_url: template_url,
        capabilities: CAPABILITIES,
        on_failure: 'DO_NOTHING'
      )
    rescue Aws::CloudFormation::Errors::AlreadyExistsException
      _update_stack stack_name: stack_name, template_url: template_url
    end

    def hosted_zone_name(hosted_zone_id)
      @route53_client.get_hosted_zone(
        id: hosted_zone_id
      ).hosted_zone.name.chomp '.'
    end

    def _update_stack(stack_name:, template_url:)
      @cloudformation_client.update_stack(
        stack_name: stack_name,
        template_url: template_url,
        capabilities: CAPABILITIES
      )
    rescue Aws::CloudFormation::Errors::ValidationError => error
      raise error unless error.message.eql?(
        'No updates are to be performed.'
      )
    end

    def delete_stack(stack_name)
      @cloudformation_client.delete_stack(
        stack_name: stack_name
      )
    end

    def _create_aws_credentials
      @aws_credentials = Aws::Credentials.new(
        @credentials['access_key_id'],
        @credentials['secret_access_key']
      )
    end

    def _create_s3_client
      @s3_client = ::Aws::S3::Client.new(
        region: @region,
        signature_version: 'v4',
        credentials: @aws_credentials
      )
    end

    def _create_cloudformation_client
      @cloudformation_client = ::Aws::CloudFormation::Client.new(
        region: @region,
        credentials: @aws_credentials
      )
    end

    def _create_route53_client
      @route53_client = ::Aws::Route53::Client.new(
        region: @region,
        credentials: @aws_credentials
      )
    end

    private(
      :_create_aws_credentials,
      :_create_s3_client,
      :_create_cloudformation_client,
      :_create_route53_client,
      :_update_stack
    )
  end
  # rubocop:enable Metrics/ClassLength
end
