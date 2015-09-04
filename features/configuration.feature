Feature: JSON configuration data
  In order to test a formatron stack definition without affecting production resources
  As a maintainer of formatron stacks
  I want to be able to deploy separate target configurations from the same definition

  Rules:
  - Target specific S3 keys should be properly namespaced
  - Configuration uploaded to S3 should be encrypted
  - Configuration key values loaded from files/directories should override JSON specified keys
  - Target specific configuration should override default configuration

  Scenario Outline: deploy a configuration only stack with only Formatron automatic values
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
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the config should be uploaded to S3 bucket <bucket> with key <target>/<name>/config.json, KMS key <KMS key> and content
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<target>",
        "formatronName": "<name>",
        "formatronConfigS3Key": "<target>/<name>/config.json",
        "formatronCloudformationS3Key": "<target>/<name>/cloudformation",
        "formatronOpsworksS3Key": "<target>/<name>/opsworks",
        "formatronOpscodeS3Key": "<target>/<name>/opscode",
        "<name>": {
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a configuration only stack with default JSON values
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
    And a config/_default/_default.json file with content
      """
      {
        "param": "<parameter>"
      }
      """
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the config should be uploaded to S3 bucket <bucket> with key <target>/<name>/config.json, KMS key <KMS key> and content
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<target>",
        "formatronName": "<name>",
        "formatronConfigS3Key": "<target>/<name>/config.json",
        "formatronCloudformationS3Key": "<target>/<name>/cloudformation",
        "formatronOpsworksS3Key": "<target>/<name>/opsworks",
        "formatronOpscodeS3Key": "<target>/<name>/opscode",
        "<name>": {
          "param": "<parameter>"
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    Examples:
      | prefix | name | target | parameter | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a configuration only stack with JSON values merged from a file tree
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
    And a config/_default/_default.json file with content
      """
      {
        "param1": "<parameter 1>"
      }
      """
    And a config/_default/subParams/_default.json file with content
      """
      {
        "param2": "<parameter 2>"
      }
      """
    And a config/_default/param3 file with content
      """
      <parameter 3>
      """
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the config should be uploaded to S3 bucket <bucket> with key <target>/<name>/config.json, KMS key <KMS key> and content
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<target>",
        "formatronName": "<name>",
        "formatronConfigS3Key": "<target>/<name>/config.json",
        "formatronCloudformationS3Key": "<target>/<name>/cloudformation",
        "formatronOpsworksS3Key": "<target>/<name>/opsworks",
        "formatronOpscodeS3Key": "<target>/<name>/opscode",
        "<name>": {
          "param1": "<parameter 1>",
          "param3": "<parameter 3>",
          "subParams": {
            "param2": "<parameter 2>"
          }
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    Examples:
      | prefix | name | target | parameter 1 | parameter 2 | parameter 3 | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1_1 | test_param_1_2 | test_param_1_3 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2_1 | test_param_2_2 | test_param_2_3 | production_2 | production_param_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | my_prod_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a configuration only stack with default and target specific JSON values
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
    And a config/_default/_default.json file with content
      """
      {
        "param1": "<parameter 1>",
        "param2": "<parameter 2>"
      }
      """
    And a config/<test target>/_default.json file with content
      """
      {
        "param2": "<test parameter 2>",
        "param3": "<test parameter 3>"
      }
      """
    And a config/<production target>/_default.json file with content
      """
      {
        "param2": "<production parameter 2>",
        "param3": "<production parameter 3>"
      }
      """
    When  I deploy the formatron stack with target <test target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the config should be uploaded to S3 bucket <bucket> with key <test target>/<name>/config.json, KMS key <KMS key> and content
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<test target>",
        "formatronName": "<name>",
        "formatronConfigS3Key": "<test target>/<name>/config.json",
        "formatronCloudformationS3Key": "<test target>/<name>/cloudformation",
        "formatronOpsworksS3Key": "<test target>/<name>/opsworks",
        "formatronOpscodeS3Key": "<test target>/<name>/opscode",
        "<name>": {
          "param1": "<parameter 1>",
          "param2": "<test parameter 2>",
          "param3": "<test parameter 3>"
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    Examples:
      | prefix | name | parameter 1 | parameter 2 | test target | test parameter 2 | test parameter 3 | production target | production parameter 2 | production parameter 3 | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | param_1_1 | param_1_2 | test_1 | test_param_1_2 | test_param_1_3 | production_1 | production_param_1_2 | production_param_1_3 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | param_2_1 | param_2_2 | test_2 | test_param_2_2 | test_param_2_3 | production_2 | production_param_2_2 | production_param_2_3 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |
