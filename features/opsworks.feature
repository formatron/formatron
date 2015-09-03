Feature: OpsWorks stack support
  In order to configure EC2 instances
  As a maintainer of formatron stacks
  I want to be able to deploy OpsWorks stacks as part of my Cloudformation stacks

  Rules:
  - OpsWorks stack cookbook bundles should be uploaded to S3
  - S3 keys should correspond to the 'formatronOpsworksS3Key' automatic configuration

  Scenario Outline: deploy multiple OpsWorks cookbook bundles
    Given a Formatron project
    And a credentials.json file with content
      """
      {
        "accessKeyId": "<AWS access key ID>",
        "secretAccessKey": "<AWS secret access key>"
      }
      """
    And a Formatronfile file with content
      """
      name '<name>'
      prefix '<prefix>'
      s3_bucket '<bucket>'
      region '<region>'
      kms_key '<KMS key>'
      """
    And an opsworks/first_stack/metadata.rb file with content
      """
      name 'first_stack'
      """
    And an opsworks/second_stack/metadata.rb file with content
      """
      name 'second_stack'
      """
    When I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the following cookbooks should have been vendored to the given directories
      | cookbook | directory |
      | opsworks/first_stack | vendor/first_stack |
      | opsworks/second_stack | vendor/second_stack |
    And the following vendored cookbooks should be tarballed and uploaded to S3 bucket <bucket> with the given keys
      | vendored cookbook | S3 key |
      | vendor/first_stack | <target>/<name>/opsworks/first_stack.tar.gz |
      | vendor/second_stack | <target>/<name>/opsworks/second_stack.tar.gz |
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |
