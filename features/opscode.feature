Feature: Opscode Chef Server support
  In order to configure EC2 instances without OpsWorks so that instance IDs and IP addresses can be known as the CloudFormation stack is deployed
  As a maintainer of formatron stacks
  I want to be able to deploy a Chef Server and Chef Nodes as part of a CloudFormation stack

  Rules:
  - A special case should be supported to deploy a Chef Server and add it as a node to itself
  - The initial users Chef Server keys should be securely made available for use by other stacks
  - Node cookbooks should be uploaded to the Chef Server using environments to pin the versions
  - Nodes should be bootstrapped from the chef server on CloudFormation stack deployment

  Scenario Outline: deploy a CloudFormation stack containing only a Chef Server
    Given a Formatron project
    And a credentials.json file with content
      """
      {
        "region": "<region>",
        "accessKeyId": "<AWS access key ID>",
        "secretAccessKey": "<AWS secret access key>"
      }
      """
    And a Formatronfile file with content
      """
      name '<name>'
      prefix '<prefix>'
      s3_bucket '<bucket>'
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
