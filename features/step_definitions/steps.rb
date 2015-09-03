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
  AWS[ ]access[ ]key[ ]ID[ ](\w+)[ ]
  and[ ]AWS[ ]secret[ ]access[ ]key[ ](\w+)[ ]
  should[ ]be[ ]used[ ]when[ ]communicating[ ]with[ ]AWS
$/x) do |access_key_id, secret_access_key|
  expect(Aws::Credentials).to have_received(:new).once.with(
    access_key_id,
    secret_access_key
  )
end

Then(/^
  the[ ]region[ ](\w+),[ ]
  AWS[ ]access[ ]key[ ]ID[ ](\w+)[ ]
  and[ ]AWS[ ]secret[ ]access[ ]key[ ](\w+)[ ]
  should[ ]be[ ]used[ ]when[ ]communicating[ ]with[ ]S3
$/x) do |region, access_key_id, secret_access_key|
  step([
    "AWS access key ID #{access_key_id}",
    "and AWS secret access key #{secret_access_key}",
    'should be used when communicating with AWS'
  ].join(' '))
  expect(Aws::S3::Client).to have_received(:new).once.with(
    region: region,
    signature_version: 'v4',
    credentials: @credentials
  )
end

Then(/^
  the[ ]region[ ](\w+),[ ]
  AWS[ ]access[ ]key[ ]ID[ ](\w+)[ ]
  and[ ]AWS[ ]secret[ ]access[ ]key[ ](\w+)[ ]
  should[ ]be[ ]used[ ]when[ ]communicating[ ]with[ ]CloudFormation
$/x) do |region, access_key_id, secret_access_key|
  step([
    "AWS access key ID #{access_key_id}",
    "and AWS secret access key #{secret_access_key}",
    'should be used when communicating with AWS'
  ].join(' '))
  expect(Aws::CloudFormation::Client).to have_received(:new).once.with(
    region: region,
    credentials: @credentials
  )
end

Then(/^
  the[ ]region[ ](\w+),[ ]
  AWS[ ]access[ ]key[ ]ID[ ](\w+)[ ]
  and[ ]AWS[ ]secret[ ]access[ ]key[ ](\w+)[ ]
  should[ ]be[ ]used[ ]when[ ]communicating[ ]with[ ]AWS
$/x) do |region, access_key_id, secret_access_key|
  step([
    "the region #{region},",
    "AWS access key ID #{access_key_id}",
    "and AWS secret access key #{secret_access_key}",
    'should be used when communicating with S3'
  ].join(' '))
  step([
    "the region #{region},",
    "AWS access key ID #{access_key_id}",
    "and AWS secret access key #{secret_access_key}",
    'should be used when communicating with CloudFormation'
  ].join(' '))
end

Then(/^
  the[ ]config[ ]should[ ]be[ ]uploaded[ ]to[ ]S3[ ]bucket[ ](\w+)[ ]
  with[ ]key[ ]([^\s,]+),[ ]
  KMS[ ]key[ ](\w+)[ ]
  and[ ]content
$/x) do |bucket, key, kms_key, content|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: content.to_s,
    server_side_encryption: 'aws:kms',
    ssekms_key_id: kms_key
  )
end

Then(/^
  the[ ]cloudformation[ ]template[ ]should[ ]be[ ]
  validated[ ]with[ ]content[ ]matching[ ]([^\s]+)
$/x) do |relative_path|
  expect(@cloudformation).to have_received(:validate_template).once.with(
    template_body: @fp.files[relative_path]
  )
end

Then(/^
  the[ ]cloudformation[ ]template[ ]should[ ]be[ ]
  uploaded[ ]to[ ]S3[ ]bucket[ ](\w+)[ ]
  with[ ]key[ ]([^\s]+)[ ]
  and[ ]content[ ]matching[ ]([^\s]+)
$/x) do |bucket, key, relative_path|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: @fp.files[relative_path]
  )
end

Then(/^
  the[ ]cloudformation[ ]stack[ ]should[ ]be[ ]
  created[ ]with[ ]name[ ]([^\s,]+),[ ]
  template[ ]url[ ]([^\s]+)
$/x) do |name, url|
  expect(@cloudformation).to have_received(:create_stack).once.with(
    stack_name: name,
    template_url: url,
    capabilities: ['CAPABILITY_IAM'],
    on_failure: 'DO_NOTHING',
    parameters: [
    ]
  )
end

Then(/^
  the[ ]cloudformation[ ]stack[ ]should[ ]be[ ]
  created[ ]with[ ]name[ ]([^\s,]+),[ ]
  template[ ]url[ ]([^\s]+)[ ]
  and[ ]parameters
$/x) do |name, url, params|
  expect(@cloudformation).to have_received(:create_stack).once.with(
    stack_name: name,
    template_url: url,
    capabilities: ['CAPABILITY_IAM'],
    on_failure: 'DO_NOTHING',
    parameters: params.hashes.map do |param|
      {
        parameter_key: param[:parameter],
        parameter_value: param[:value],
        use_previous_value: false
      }
    end
  )
end
