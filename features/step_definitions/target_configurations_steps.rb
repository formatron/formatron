include Formatron::Cucumber::Support

Given(/^a Formatron project$/) do
  @fp = FormatronProject.new
end

Given(/^a ([^\s]+) file with content$/) do |relative_path, content|
  @fp.add_file relative_path, content
end

When(/^I deploy the formatron stack with target (\w+)$/) do |target|
  @credentials = double
  @s3_client = double
  allow(@s3_client).to receive(:put_object)
  @cloudformation = double
  allow(@cloudformation).to receive(:validate_template)
  allow(@cloudformation).to receive(:create_stack)
  allow(Aws::Credentials).to receive(:new) { @credentials }
  allow(Aws::S3::Client).to receive(:new) { @s3_client }
  allow(Aws::CloudFormation::Client).to receive(:new) { @cloudformation }
  @fp.deploy target
end

Then(/^
  the[ ]region[ ](\w+),[ ]
  AWS[ ]access[ ]key[ ]ID[ ](\w+)[ ]
  and[ ]AWS[ ]secret[ ]access[ ]key[ ](\w+)[ ]
  should[ ]be[ ]used[ ]when[ ]communicating[ ]with[ ]AWS
$/x) do |region, access_key_id, secret_access_key|
  expect(Aws::Credentials).to have_received(:new).once.with(
    access_key_id,
    secret_access_key
  )
  expect(Aws::S3::Client).to have_received(:new).once.with(
    region: region,
    signature_version: 'v4',
    credentials: @credentials
  )
  expect(Aws::CloudFormation::Client).to have_received(:new).once.with(
    region: region,
    credentials: @credentials
  )
  expect(@s3_client).to have_received(:put_object).twice
  expect(@cloudformation).to have_received(:validate_template).once
  expect(@cloudformation).to have_received(:create_stack).once
end

Then(/
  ^the config should be uploaded to S3 bucket (\w+)
  with key ([^\s,]+),
  KMS key (\w+)
  and content$
/x) do |bucket, key, kms_key, content|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: content.to_s,
    server_side_encryption: 'aws:kms',
    ssekms_key_id: kms_key
  )
end

Then(/
  ^the cloudformation template should be
  validated with content matching ([^\s]+)$
/x) do |relative_path|
  expect(@cloudformation).to have_received(:validate_template).once.with(
    template_body: @fp.files[relative_path]
  )
end

Then(/
  ^the cloudformation template should be
  uploaded to S3 bucket (\w+)
  with key ([^\s]+)
  and content matching ([^\s]+)$
/x) do |bucket, key, relative_path|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: @fp.files[relative_path]
  )
end

Then(/
  ^the cloudformation stack should be
  created with name ([^\s,]+),
  template url ([^\s]+)
  and parameter (\w+)
/x) do |name, url, param|
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
