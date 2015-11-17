require 'spec_helper'
require 'formatron/aws'

# namespacing for tests
# rubocop:disable Metrics/ClassLength
class Formatron
  describe AWS do
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
      @route53_client = instance_double('Aws::Route53::Client')
      route53_client_class = class_double(
        'Aws::Route53::Client'
      ).as_stubbed_const
      expect(route53_client_class).to receive(:new).with(
        region: region,
        credentials: aws_credentials
      ).once { @route53_client }
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
        @aws = AWS.new(
          credentials: File.join('test', 'credentials.json')
        )
      end

      describe '#region' do
        it 'should return the region' do
          expect(@aws.region).to eql region
        end
      end

      describe '#upload_file' do
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
          @aws.upload_file(
            kms_key: kms_key,
            bucket: bucket,
            key: key,
            content: content
          )
        end
      end

      describe '#delete_file' do
        bucket = 'bucket'
        key = 'key'

        it 'should delete the key from the bucket' do
          expect(@s3_client).to receive(:delete_object).once.with(
            bucket: bucket,
            key: key
          )
          @aws.delete_file(
            bucket: bucket,
            key: key
          )
        end
      end

      describe '#download_file' do
        bucket = 'bucket'
        key = 'key'
        path = 'path'

        it 'should download the file from S3' do
          expect(@s3_client).to receive(:get_object).once.with(
            response_target: path,
            bucket: bucket,
            key: key
          )
          @aws.download_file(
            bucket: bucket,
            key: key,
            path: path
          )
        end
      end

      describe '#get_file' do
        bucket = 'bucket'
        key = 'key'
        content = 'content'

        it 'should get the file content from S3' do
          expect(@s3_client).to receive(:get_object).once.with(
            bucket: bucket,
            key: key
          ) { S3GetObjectResponse.new content }
          expect(
            @aws.get_file(
              bucket: bucket,
              key: key
            )
          ).to eql content
        end
      end

      describe '#deploy_stack' do
        stack_name = 'stack_name'
        template_url = 'template_url'
        parameters = {
          'param1' => 'param1',
          'param2' => 'param2'
        }
        aws_parameters = parameters.map do |key, value|
          {
            parameter_key: key,
            parameter_value: value,
            use_previous_value: false
          }
        end

        context 'when the stack has not yet been created' do
          it 'should create the stack' do
            expect(@cloudformation_client).to receive(:create_stack).once.with(
              stack_name: stack_name,
              template_url: template_url,
              capabilities: ['CAPABILITY_IAM'],
              on_failure: 'DO_NOTHING',
              parameters: aws_parameters
            )
            @aws.deploy_stack(
              stack_name: stack_name,
              template_url: template_url,
              parameters: parameters
            )
          end
        end

        context 'when the stack already exists' do
          it 'should create the stack' do
            expect(@cloudformation_client).to receive(:create_stack).once.with(
              stack_name: stack_name,
              template_url: template_url,
              capabilities: ['CAPABILITY_IAM'],
              on_failure: 'DO_NOTHING',
              parameters: aws_parameters
            ) do
              fail Aws::CloudFormation::Errors::AlreadyExistsException.new(
                nil,
                'exists'
              )
            end
            expect(@cloudformation_client).to receive(:update_stack).once.with(
              stack_name: stack_name,
              template_url: template_url,
              capabilities: ['CAPABILITY_IAM'],
              parameters: aws_parameters
            )
            @aws.deploy_stack(
              stack_name: stack_name,
              template_url: template_url,
              parameters: parameters
            )
          end
        end

        context 'when an update contains no changes' do
          it 'should create the stack' do
            expect(@cloudformation_client).to receive(:create_stack).once.with(
              stack_name: stack_name,
              template_url: template_url,
              capabilities: ['CAPABILITY_IAM'],
              on_failure: 'DO_NOTHING',
              parameters: aws_parameters
            ) do
              fail Aws::CloudFormation::Errors::AlreadyExistsException.new(
                nil,
                'exists'
              )
            end
            expect(@cloudformation_client).to receive(:update_stack).once.with(
              stack_name: stack_name,
              template_url: template_url,
              capabilities: ['CAPABILITY_IAM'],
              parameters: aws_parameters
            ) do
              fail Aws::CloudFormation::Errors::ValidationError.new(
                nil,
                'No updates are to be performed.'
              )
            end
            @aws.deploy_stack(
              stack_name: stack_name,
              template_url: template_url,
              parameters: parameters
            )
          end
        end
      end

      describe '#delete_stack' do
        stack_name = 'stack_name'

        it 'should delete the stack' do
          expect(@cloudformation_client).to receive(:delete_stack).once.with(
            stack_name: stack_name
          )
          @aws.delete_stack stack_name: stack_name
        end
      end

      describe '#stack_outputs' do
        stack_name = 'stack_name'

        it 'should return the outputs for the CloudFormation stack' do
          outputs = {
            'output1' => 'output1',
            'output2' => 'output2'
          }
          expect(@cloudformation_client).to receive(:describe_stacks).once.with(
            stack_name: stack_name
          ) do
            CloudformationDescribeStacksResponse.new outputs, 'CREATE_COMPLETE'
          end
          expect(
            @aws.stack_outputs stack_name: stack_name
          ).to eql outputs
        end
      end

      describe '#hosted_zone_name' do
        hosted_zone_id = 'hosted_zone_id'
        hosted_zone_name_with_dot = 'hosted_zone_name.'
        hosted_zone_name = 'hosted_zone_name'

        it 'should return the Route53 hosted zone name for the given ID' do
          expect(@route53_client).to receive(:get_hosted_zone).once.with(
            id: hosted_zone_id
          ) { Route53GetHostedZoneResponse.new hosted_zone_name_with_dot }
          expect(@aws.hosted_zone_name(hosted_zone_id)).to eql hosted_zone_name
        end
      end

      describe '#stack_ready!' do
        before :each do
          @stack_name = 'stack_name'
          @not_ready_status = 'NOT_READY'
        end

        context 'when the stack status is ROLLBACK_COMPLETE' do
          before :each do
            expect(@cloudformation_client).to receive(
              :describe_stacks
            ).once.with(
              stack_name: @stack_name
            ) do
              CloudformationDescribeStacksResponse.new [], 'ROLLBACK_COMPLETE'
            end
          end

          it 'should do nothing' do
            @aws.stack_ready! stack_name: @stack_name
          end
        end

        context 'when the stack status is CREATE_COMPLETE' do
          before :each do
            expect(@cloudformation_client).to receive(
              :describe_stacks
            ).once.with(
              stack_name: @stack_name
            ) do
              CloudformationDescribeStacksResponse.new [], 'CREATE_COMPLETE'
            end
          end

          it 'should do nothing' do
            @aws.stack_ready! stack_name: @stack_name
          end
        end

        context 'when the stack status is UPDATE_COMPLETE' do
          before :each do
            expect(@cloudformation_client).to receive(
              :describe_stacks
            ).once.with(
              stack_name: @stack_name
            ) do
              CloudformationDescribeStacksResponse.new [], 'UPDATE_COMPLETE'
            end
          end

          it 'should do nothing' do
            @aws.stack_ready! stack_name: @stack_name
          end
        end

        context 'when the stack status is UPDATE_ROLLBACK_COMPLETE' do
          before :each do
            expect(@cloudformation_client).to receive(
              :describe_stacks
            ).once.with(
              stack_name: @stack_name
            ) do
              CloudformationDescribeStacksResponse.new(
                [],
                'UPDATE_ROLLBACK_COMPLETE'
              )
            end
          end

          it 'should do nothing' do
            @aws.stack_ready! stack_name: @stack_name
          end
        end

        context 'when the stack status is anything else' do
          before :each do
            expect(@cloudformation_client).to receive(
              :describe_stacks
            ).once.with(
              stack_name: @stack_name
            ) do
              CloudformationDescribeStacksResponse.new [], @not_ready_status
            end
          end

          it 'should raise an error' do
            expect { @aws.stack_ready! stack_name: @stack_name }.to raise_error(
              "CloudFormation stack, #{@stack_name}, is not " \
              "ready: #{@not_ready_status}"
            )
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
