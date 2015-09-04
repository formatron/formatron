Feature: Formatron stacks can depend on other Formatron stacks
  In order to create infrastructure using multple stacks that share configuration data and still follow the DRY principle
  As a maintainer of formatron stacks
  I want to be able to depend on other stacks merging their configuration and outputs

  Rules:
  - Dependencies must share the same AWS region as the local stack
  - Dependencies must share the same S3 bucket as the local stack
  - Dependency configuration should be loaded for the same target
  - Local configuration should override dependency configuration
  - Dependency configurations should override already loaded dependency configurations as they are loaded
  - Dependency configurations should be loaded in the order they are specified
  - CloudFormation outputs of dependencies should be made available in the `config` object
  - The existence of an associated CloudFormation stack will be signalled by an empty `formatronOutputs` object

  Scenario Outline: The local stack depends on a stack with CloudFormation outputs and both stacks depend on a third stack without CloudFormation outputs
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
      s3_bucket '<bucket>'
      depends '<dependency 1>'
      depends '<dependency 2>'
      """
    And a config/_default/_default.json file with content
      """
      {
        "param1": "param_1",
        "param2": "param_2",
        "param3": "param_3"
      }
      """
    And an already deployed Formatron stack called <dependency 1>
    And the Formatron stack called <dependency 1> has configuration
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<target>",
        "formatronName": "<dependency 1>",
        "formatronConfigS3Key": "<target>/<dependency 1>/config.json",
        "formatronCloudformationS3Key": "<target>/<dependency 1>/cloudformation",
        "formatronOpsworksS3Key": "<target>/<dependency 1>/opsworks",
        "formatronOpscodeS3Key": "<target>/<dependency 1>/opscode",
        "<dependency 1>": {
          "param1": "dependency_1_param_1",
          "param2": "dependency_1_param_2",
          "param3": "dependency_1_param_3"
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    And an already deployed Formatron stack called <dependency 2>
    And the Formatron stack called <dependency 2> has configuration
      """
      {
        "formatronRegion": "<region>",
        "formatronTarget": "<target>",
        "formatronName": "<dependency 2>",
        "formatronConfigS3Key": "<target>/<dependency 2>/config.json",
        "formatronCloudformationS3Key": "<target>/<dependency 2>/cloudformation",
        "formatronOpsworksS3Key": "<target>/<dependency 2>/opsworks",
        "formatronOpscodeS3Key": "<target>/<dependency 2>/opscode",
        "<dependency 2>": {
          "param1": "dependency_2_param_1",
          "param2": "dependency_2_param_2",
          "param3": "dependency_2_param_3",
          "formatronOutputs": {
          }
        },
        "<dependency 1>": {
          "param1": "dependency_1_param_1",
          "param2": "dependency_1_param_2",
          "param3": "dependency_1_param_3"
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>"
      }
      """
    And the Formatron stack called <dependency 2> has CloudFormation outputs
      | name  | value |
      | output1 | dependency_2_output_1 |
      | output2 | dependency_2_output_2 |
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And dependency configuration should be downloaded from S3 bucket <bucket> with key <target>/<dependency 1>/config.json
    And dependency configuration should be downloaded from S3 bucket <bucket> with key <target>/<dependency 2>/config.json
    And dependency CloudFormation outputs should be loaded from CloudFormation stack <prefix>-<dependency 2>-<target>
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
        "<dependency 2>": {
          "param1": "dependency_2_param_1",
          "param2": "dependency_2_param_2",
          "param3": "dependency_2_param_3",
          "formatronOutputs": {
            "output1": "dependency_2_output_1",
            "output2": "dependency_2_output_2"
          }
        },
        "<dependency 1>": {
          "param1": "dependency_1_param_1",
          "param2": "dependency_1_param_2",
          "param3": "dependency_1_param_3"
        },
        "formatronPrefix": "<prefix>",
        "formatronS3Bucket": "<bucket>",
        "formatronKmsKey": "<KMS key>",
        "<name>": {
          "param1": "param_1",
          "param2": "param_2",
          "param3": "param_3"
        }
      }
      """
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key | dependency 1 | dependency 2 |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 | dependency_1_1 | dependency_1_2 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 | dependency_2_1 | dependency_2_2 |
