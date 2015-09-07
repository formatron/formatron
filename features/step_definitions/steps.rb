include Formatron::Cucumber::Support

Given(/^a Formatron project$/) do
  @fp = FormatronProject.new
  @stacks = {}
  @s3_puts = {}
  @s3_keys = {}
end

Given(/^an? ([^\s]+) file with content$/) do |relative_path, content|
  @fp.add_file relative_path, content
end

Given(/^an? ([^\s]+) S3 key with content$/) do |key, content|
  @s3_keys[key] = content
end

Given(/^the CloudFormation stack already exists$/) do
  @fp.cloudformation_stack_exists = true
end

Given(/^
  an[ ]already[ ]deployed[ ]Formatron[ ]stack[ ]called[ ](\w+)
$/x) do |stack|
  @stacks[stack] = FormatronStack.new
end

Given(/^
  the[ ]Formatron[ ]stack[ ]called[ ](\w+)[ ]has[ ]configuration
$/x) do |stack, configuration|
  @stacks[stack].configuration = configuration
end

Given(/^
  the[ ]Formatron[ ]stack[ ]called[ ](\w+)[ ]has[ ]CloudFormation[ ]outputs
$/x) do |stack, outputs|
  @stacks[stack].outputs = outputs.hashes
end

When(/^I deploy the formatron stack with target (\w+)$/) do |target|
  @credentials = double
  @s3_client = double
  allow(@s3_client).to receive(:put_object) do |params|
    @s3_puts[params[:key]] = params[:body]
  end
  allow(@s3_client).to receive(:get_object) do |params|
    stack = params[:key][%r{^#{target}/([^/]+)/config.json$}, 1]
    if stack
      S3GetObjectResponse.new @stacks[stack].configuration
    else
      S3GetObjectResponse.new(@s3_keys[params[:key]] || '')
    end
  end
  @cloudformation = double
  allow(@cloudformation).to receive(:validate_template)
  allow(@cloudformation).to receive(:describe_stacks) do |params|
    stack = /^[^-]+-([^-]+)-#{target}$/.match(params[:stack_name])[1]
    fail Aws::CloudFormation::Errors::ValidationError.new(
      'context',
      "Stack with id #{params[:stack_name]} does not exist"
    ) if @stacks[stack].nil?
    CloudformationDescribeStacksResponse.new @stacks[stack].outputs
  end
  allow(@cloudformation).to receive(:create_stack) do
    fail(
      Aws::CloudFormation::Errors::AlreadyExistsException.new(
        'context',
        'stack exists'
      )
    ) if @fp.cloudformation_stack_exists
  end
  allow(@cloudformation).to receive(:update_stack)
  allow(Aws::Credentials).to receive(:new) { @credentials }
  allow(Aws::S3::Client).to receive(:new) { @s3_client }
  allow(Aws::CloudFormation::Client).to receive(:new) { @cloudformation }
  @berks = class_double('Formatron::Util::Berks').as_stubbed_const
  allow(@berks).to receive(:vendor)
  @berks_instance = double
  allow(@berks_instance).to receive(:upload_environment)
  allow(@berks_instance).to receive(:unlink)
  allow(@berks).to receive(:new) { @berks_instance }
  @knife_instance = double
  allow(@knife_instance).to receive(:create_environment)
  allow(@knife_instance).to receive(:unlink)
  allow(Formatron::Util::Knife).to receive(:new) { @knife_instance }
  tar = class_double('Formatron::Util::Tar').as_stubbed_const
  allow(tar).to receive(:tar) { |dir| "tar #{dir}" }
  allow(tar).to receive(:gzip) { |tarfile| "gzip #{tarfile}" }
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
  and[ ]JSON
$/x) do |bucket, key, kms_key, json|
  expect(@s3_client).to have_received(:put_object).once.with(
    hash_including(
      bucket: bucket,
      key: key,
      server_side_encryption: 'aws:kms',
      ssekms_key_id: kms_key
    )
  )
  config = JSON.parse(json)
  expect(JSON.parse(@s3_puts[key])).to eq(config)
end

Then(/^
  (?:the|a)[ ]cloudformation[ ]template[ ]should[ ]be[ ]
  validated[ ]with[ ]content[ ]matching[ ]([^\s]+)
$/x) do |relative_path|
  expect(@cloudformation).to have_received(:validate_template).once.with(
    template_body: @fp.files[relative_path]
  )
end

Then(/^
  (?:the|a)[ ]cloudformation[ ]template[ ]should[ ]be[ ]
  validated[ ]with[ ]content[ ]matching
$/x) do |content|
  expect(@cloudformation).to have_received(:validate_template).once.with(
    template_body: content
  )
end

Then(/^
  (?:the|a)[ ]cloudformation[ ]template[ ]should[ ]be[ ]
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
  (?:the|a)[ ]cloudformation[ ]template[ ]should[ ]be[ ]
  uploaded[ ]to[ ]S3[ ]bucket[ ](\w+)[ ]
  with[ ]key[ ]([^\s]+)[ ]
  and[ ]content[ ]matching
$/x) do |bucket, key, content|
  expect(@s3_client).to have_received(:put_object).once.with(
    bucket: bucket,
    key: key,
    body: content
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
  updated[ ]with[ ]name[ ]([^\s,]+),[ ]
  template[ ]url[ ]([^\s]+)
$/x) do |name, url|
  expect(@cloudformation).to have_received(:update_stack).once.with(
    stack_name: name,
    template_url: url,
    capabilities: ['CAPABILITY_IAM'],
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

Then(/^
  the[ ]following[ ]cookbooks[ ]should[ ]have[ ]
  been[ ]vendored[ ]to[ ]the[ ]given[ ]directories
$/x) do |vendor_calls|
  vendor_calls.hashes.each do |vendor_call|
    args = [
      File.join(@fp.dir, vendor_call[:cookbook]),
      File.join(@fp.dir, vendor_call[:directory])
    ]
    args.push true if vendor_call['with lockfile'] == 'true'
    expect(@berks).to have_received(:vendor).once.with(*args)
  end
end

Then(/^
  the[ ]following[ ]vendored[ ]cookbooks[ ]should[ ]be[ ]
  tarballed[ ]and[ ]uploaded[ ]to[ ]S3[ ]bucket[ ](\w+)[ ]
  with[ ]the[ ]given[ ]keys
$/x) do |bucket, vendored_cookbooks|
  vendored_cookbooks.hashes.each do |vendored_cookbook|
    path = File.join(@fp.dir, vendored_cookbook['vendored cookbook'])
    expect(@s3_client).to have_received(:put_object).once.with(
      bucket: bucket,
      key: vendored_cookbook['S3 key'],
      body: "gzip tar #{path}"
    )
  end
end

Then(/^
  .+[ ]should[ ]be[ ]downloaded[ ]
  from[ ]S3[ ]bucket[ ](\w+)[ ]
  with[ ]key[ ]([^\s]+)
$/x) do |bucket, key|
  expect(@s3_client).to have_received(:get_object).once.with(
    bucket: bucket,
    key: key
  )
end

Then(/^
  dependency[ ]CloudFormation[ ]outputs[ ]should[ ]be[ ]
  loaded[ ]from[ ]CloudFormation[ ]stack[ ]([^\s]+)
$/x) do |name|
  expect(@cloudformation).to have_received(:describe_stacks).once.with(
    stack_name: name
  )
end

Then(/^
  the[ ]url[ ]([^\s,]+),[ ]
  user[ ](\w+),[ ]
  user[ ]key[ ](\w+),[ ]
  organization[ ](\w+)[ ]and[ ]
  the[ ]ssl[ ]verify[ ]flag[ ](\w+)[ ]
  should[ ]be[ ]used[ ]to[ ]communicate[ ]
  with[ ]the[ ]Chef[ ]Server
$/x) do |url, user, user_key, organization, ssl_verify|
  expect(@berks).to have_received(:new).with(
    url,
    user,
    user_key,
    organization,
    ssl_verify == 'true'
  )
  expect(Formatron::Util::Knife).to have_received(:new).with(
    url,
    user,
    user_key,
    organization,
    ssl_verify == 'true'
  )
  expect(@berks_instance).to have_received(:unlink).with(no_args)
  expect(@knife_instance).to have_received(:unlink).with(no_args)
end

Then(/^
  an[ ]environment[ ]called[ ](\w+)[ ]
  should[ ]be[ ]created[ ]on[ ]the[ ]Chef[ ]Server
$/x) do |environment|
  expect(@knife_instance).to have_received(:create_environment).with(
    environment
  )
end

Then(/^
  the[ ]cookbooks[ ]for[ ]the[ ](\w+)[ ]environment[ ]
  should[ ]be[ ]pinned[ ]from[ ]the[ ]([^\s]+)[ ]cookbook
$/x) do |environment, cookbook|
  expect(@berks_instance).to have_received(:upload_environment).with(
    File.join(@fp.dir, cookbook),
    environment
  )
end
