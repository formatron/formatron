require 'aws-sdk'
require_relative 'aws/cloud_formation_stack'

class Formatron
  # shared AWS clients
  # rubocop:disable Metrics/ClassLength
  class AWS
    attr_reader :region

    REGIONS = {
      'us-east-1' => {
        'ubuntu' => 'ami-fce3c696',
        'windows' => 'ami-3586ac5f'
      },
      'us-west-1' => {
        'ubuntu' => 'ami-06116566',
        'windows' => 'ami-95fd8bf5'
      },
      'us-west-2' => {
        'ubuntu' => 'ami-9abea4fb',
        'windows' => 'ami-df8767bf'
      },
      'eu-west-1' => {
        'ubuntu' => 'ami-f95ef58a',
        'windows' => 'ami-8519a9f6'
      },
      'eu-central-1' => {
        'ubuntu' => 'ami-87564feb',
        'windows' => 'ami-5dd2c931'
      },
      'ap-northeast-1' => {
        'ubuntu' => 'ami-a21529cc',
        'windows' => 'ami-14b8bc7a'
      },
      'ap-northeast-2' => {
        'ubuntu' => 'ami-09dc1267',
        'windows' => 'ami-d31dd3bd'
      },
      'ap-southeast-1' => {
        'ubuntu' => 'ami-25c00c46',
        'windows' => 'ami-9801cffb'
      },
      'ap-southeast-2' => {
        'ubuntu' => 'ami-6c14310f',
        'windows' => 'ami-db0a2db8'
      },
      'sa-east-1' => {
        'ubuntu' => 'ami-0fb83963',
        'windows' => 'ami-828e0dee'
      }
    }

    CAPABILITIES = %w(CAPABILITY_IAM)

    STACK_READY_STATES = %w(
      CREATE_COMPLETE
      UPDATE_COMPLETE
      UPDATE_ROLLBACK_COMPLETE
      ROLLBACK_COMPLETE
    )

    def initialize(credentials:)
      @credentials = JSON.parse(File.read(credentials))
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

    def file_exists?(bucket:, key:)
      @s3_client.list_objects(
        bucket: bucket,
        prefix: key
      ).contents.length > 0
    end

    def delete_file(bucket:, key:)
      @s3_client.delete_object(
        bucket: bucket,
        key: key
      )
    end

    def download_file(bucket:, key:, path:)
      @s3_client.get_object(
        bucket: bucket,
        key: key,
        response_target: path
      )
    end

    def get_file(bucket:, key:)
      @s3_client.get_object(
        bucket: bucket,
        key: key
      ).body.read
    end

    # rubocop:disable Metrics/MethodLength
    def deploy_stack(stack_name:, template_url:, parameters:)
      aws_parameters = parameters.map do |key, value|
        {
          parameter_key: key,
          parameter_value: value,
          use_previous_value: false
        }
      end
      cloud_formation_stack = Formatron::AWS::CloudFormationStack.new(
        stack_name: stack_name,
        client: @cloudformation_client
      )
      if !cloud_formation_stack.exists?
        cloud_formation_stack.create(
          template_url: template_url,
          parameters: aws_parameters
        )
      else
        cloud_formation_stack.update(
          template_url: template_url,
          parameters: aws_parameters
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def hosted_zone_name(hosted_zone_id)
      @route53_client.get_hosted_zone(
        id: hosted_zone_id
      ).hosted_zone.name.chomp '.'
    end

    def delete_stack(stack_name:)
      cloud_formation_stack = Formatron::AWS::CloudFormationStack.new(
        stack_name: stack_name,
        client: @cloudformation_client
      )
      cloud_formation_stack.delete if cloud_formation_stack.exists?
    end

    def stack_outputs(stack_name:)
      description = @cloudformation_client.describe_stacks(
        stack_name: stack_name
      ).stacks[0]
      status = description.stack_status
      fail "CloudFormation stack, #{stack_name}, " \
           "is not ready: #{status}" unless STACK_READY_STATES.include? status
      description.outputs.each_with_object({}) do |output, outputs|
        outputs[output.output_key] = output.output_value
      end
    end

    def stack_ready!(stack_name:)
      status = @cloudformation_client.describe_stacks(
        stack_name: stack_name
      ).stacks[0].stack_status
      fail "CloudFormation stack, #{stack_name}, " \
           "is not ready: #{status}" unless STACK_READY_STATES.include? status
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
      :_create_route53_client
    )
  end
  # rubocop:enable Metrics/ClassLength
end
