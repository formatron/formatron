include Formatron::Features::Support

Given(/a basic formatron stack definition/) do
  @fsd = FormatronStackDefinition.new
end

Given(/a prefix of (\w+)/) do |prefix|
  @fsd.prefix = prefix
end

Given(/a name of (\w+)/) do |name|
  @fsd.name = name
end

Given(/a test target name of (\w+)/) do |name|
  @fsd.test_target = name
end

Given(/a test configuration parameter of (\w+)/) do |param|
  @fsd.test_param = param
end

Given(/a production target name of (\w+)/) do |name|
  @fsd.prod_target = name
end

Given(/a production configuration parameter of (\w+)/) do |param|
  @fsd.prod_param = param
end

Given(/an S3 bucket of (\w+)/) do |bucket|
  @fsd.s3_bucket = bucket
end

Given(/a region of (\w+)/) do |region|
  @fsd.region = region
end

Given(/a test kms key of (\w+)/) do |kms_key|
  @fsd.test_kms_key = kms_key
end

Given(/a production kms key of (\w+)/) do |kms_key|
  @fsd.prod_kms_key = kms_key
end

When(/I deploy the formatron stack with target (\w+)/) do |target|
  @target = target
  @credentials = double
  @s3_client = double
  allow(@s3_client).to receive(:put_object)
  @cloudformation = double
  allow(@cloudformation).to receive(:validate_template)
  allow(@cloudformation).to receive(:create_stack)
  allow(Aws::Credentials).to receive(:new) {@credentials}
  allow(Aws::S3::Client).to receive(:new) {@s3_client}
  allow(Aws::CloudFormation::Client).to receive(:new) {@cloudformation}
  @fsd.deploy target
  expect(Aws::Credentials).to have_received(:new).once.with(
    FormatronStackDefinition::Credentials::ACCESS_KEY_ID,
    FormatronStackDefinition::Credentials::SECRET_ACCESS_KEY
  )
  expect(Aws::S3::Client).to have_received(:new).once.with(
    region: @fsd.region,
    signature_version: 'v4',
    credentials: @credentials
  )
  expect(Aws::CloudFormation::Client).to have_received(:new).once.with(
    region: @fsd.region,
    credentials: @credentials
  )
  expect(@s3_client).to have_received(:put_object).twice
  expect(@cloudformation).to have_received(:validate_template).once
  expect(@cloudformation).to have_received(:create_stack).once
end

Then(/the config should be uploaded to S3 bucket (\w+) with key ([^\s,]+), KMS key (\w+) and content/) do |bucket, key, kms_key, content|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: content.to_s,
    server_side_encryption: 'aws:kms',
    ssekms_key_id: kms_key
  )
end

Then(/the cloudformation template should be validated/) do
  expect(@cloudformation).to have_received(:validate_template).once.with(
    template_body: FormatronStackDefinition::Cloudformation::TEMPLATE_JSON
  )
end

Then(/the cloudformation template should be uploaded to S3 bucket (\w+) with key ([^\s]+)/) do |bucket, key|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: FormatronStackDefinition::Cloudformation::TEMPLATE_JSON
  )
end

Then(/the cloudformation stack should be created with name ([^\s,]+), template url ([^\s]+) and parameter (\w+)/) do |name, url, param|
  expect(@cloudformation).to have_received(:create_stack).once.with(
    stack_name: name,
    template_url: url,
    capabilities: ['CAPABILITY_IAM'],
    on_failure: 'DO_NOTHING',
    parameters: [{
      parameter_key: 'param',
      parameter_value: param,
      use_previous_value: false
    }]
  )
end
