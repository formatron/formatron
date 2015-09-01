Feature: Target configurations
  In order to test a formatron stack definition without affecting production resources
  As a maintainer of formatron stacks
  I want to be able to deploy separate target configurations from the same definition

  Rules:
  - CloudFormation stacks should be properly namespaced
  - Configuration should be loaded from target specific sources
  - Target specific S3 keys should be properly namespaced

  Scenario Outline: deploy a simple stack with only a CloudFormation template
    Given a basic formatron stack definition
    And a prefix of <prefix>
    And a name of <name>
    And a test target name of <test target>
    And a test configuration parameter of <test parameter>
    And a production target name of <production target>
    And a production configuration parameter of <production parameter>
    And an S3 bucket of <bucket>
    And a region of <region>
    And a test kms key of <test kms key>
    And a production kms key of <production kms key>
    When  I deploy the formatron stack with target <test target>
    Then the config should be uploaded to S3 bucket <bucket> with key <test target>/<name>/config.json, KMS key <test kms key> and content
      """
      {
        "formatronTarget": "<test target>",
        "formatronName": "<name>",
        "formatronConfigS3Key": "<test target>/<name>/config.json",
        "formatronCloudformationS3Key": "<test target>/<name>/cloudformation",
        "formatronOpsworksS3Key": "<test target>/<name>/opsworks",
        "formatronOpscodeS3Key": "<test target>/<name>/opscode",
        "<name>": {
          "param": "<test parameter>",
          "formatronOutputs": {
          }
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronRegion": "<region>",
        "formatronKmsKey": "<test kms key>"
      }
      """
    And the cloudformation template should be validated
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <test target>/<name>/cloudformation/main.json
    And the cloudformation stack should be created with name <prefix>-<name>-<test target>, template url https://s3.amazonaws.com/<bucket>/<test target>/<name>/cloudformation/main.json and parameter <test parameter>

    Examples:
      | prefix      | name       | test target | test parameter | production target | production parameter | bucket      | region | test kms key | production kms key |
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1 | production_1 | production_param_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | my_prod_kms_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2 | production_2 | production_param_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | my_prod_kms_key_2 |
