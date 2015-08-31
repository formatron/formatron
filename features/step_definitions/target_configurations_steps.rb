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

When(/I deploy the formatron stack with target (\w+)/) do |target|
  @fsd.deploy target
end

Then(/the cloudformation stack should be called (\w+)/) do |name|
  @fsd.outputs.cloudformation_stack.should == name
end

Then(/the cloudformation parameter should be (\w+)/) do |param|
  @fsd.outputs.cloudformation_param.should == param
end

Then(/the S3 key for the cloudformation template should be (\w+)/) do |s3_key|
  @fsd.outputs.cloudformation_s3_key.should == s3_key
end
