Feature: CloudFormation stack support
  In order to deploy actual AWS resources
  As a maintainer of formatron stacks
  I want to be able to deploy CloudFormation stacks

  Rules:
  - only the `main` CloudFormation stack should be deployed
  - other CloudFormation templates should be uploaded to S3 so thay can be used from the `main` stack
  - CloudFormation stacks should be properly namespaced
  - Target specific S3 keys should be properly namespaced
  - CloudFormation parameters can be mapped from target specific configuration
  - ERB templates should be supported
  - If a stack already exists it should be updated

  Scenario Outline: deploy a CloudFormation stack without mapped parameters
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
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And the cloudformation template should be validated with content matching cloudformation/main.json
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <target>/<name>/cloudformation/main.json and content matching cloudformation/main.json
    And the cloudformation stack should be created with name <prefix>-<name>-<target>, template url https://s3.amazonaws.com/<bucket>/<target>/<name>/cloudformation/main.json
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a CloudFormation stack that uses automatic Formatron parameters
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
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
          "formatronTarget": {
            "Type": "String"
          },
          "formatronName": {
            "Type": "String"
          },
          "formatronConfigS3Key": {
            "Type": "String"
          },
          "formatronCloudformationS3Key": {
            "Type": "String"
          },
          "formatronOpsworksS3Key": {
            "Type": "String"
          },
          "formatronOpscodeS3Key": {
            "Type": "String"
          },
          "formatronPrefix": {
            "Type": "String"
          },
          "formatronS3Bucket": {
            "Type": "String"
          },
          "formatronRegion": {
            "Type": "String"
          },
          "formatronKmsKey": {
            "Type": "String"
          }
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And the cloudformation template should be validated with content matching cloudformation/main.json
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <target>/<name>/cloudformation/main.json and content matching cloudformation/main.json
    And the cloudformation stack should be created with name <prefix>-<name>-<target>, template url https://s3.amazonaws.com/<bucket>/<target>/<name>/cloudformation/main.json and parameters
      | parameter | value |
      | formatronTarget | <target> |
      | formatronName | <name> |
      | formatronConfigS3Key | <target>/<name>/config.json |
      | formatronCloudformationS3Key | <target>/<name>/cloudformation |
      | formatronOpsworksS3Key | <target>/<name>/opsworks |
      | formatronOpscodeS3Key | <target>/<name>/opscode |
      | formatronPrefix | <prefix> |
      | formatronS3Bucket | <bucket> |
      | formatronRegion | <region> |
      | formatronKmsKey | <KMS key> |
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a CloudFormation stack with mapped parameters
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
      cloudformation do
        parameter 'param', config['<name>']['param']
      end
      """
    And a config/<test target>/_default.json file with content
      """
      {
        "param": "<test parameter>"
      }
      """
    And a config/<production target>/_default.json file with content
      """
      {
        "param": "<production parameter>"
      }
      """
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
          "param": {
            "Type": "String"
          }
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    When  I deploy the formatron stack with target <test target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And the cloudformation template should be validated with content matching cloudformation/main.json
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <test target>/<name>/cloudformation/main.json and content matching cloudformation/main.json
    And the cloudformation stack should be created with name <prefix>-<name>-<test target>, template url https://s3.amazonaws.com/<bucket>/<test target>/<name>/cloudformation/main.json and parameters
      | parameter | value |
      | param | <test parameter> |
    Examples:
      | prefix | name | test target | test parameter | production target | production parameter | bucket | region | test KMS key | production KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1 | production_1 | production_param_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | my_prod_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2 | production_2 | production_param_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | my_prod_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a CloudFormation stack using an ERB template
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
    And a config/<test target>/_default.json file with content
      """
      {
        "param": "<test parameter>"
      }
      """
    And a config/<production target>/_default.json file with content
      """
      {
        "param": "<production parameter>"
      }
      """
    And a cloudformation/main.json.erb file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
        },
        "Resources": {
          "<%= @config['formatronName'] %>": "<%= @config['<name>']['param'] %>"
        },
        "Outputs": {
        }
      }
      """
    When  I deploy the formatron stack with target <test target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And the cloudformation template should be validated with content matching
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
        },
        "Resources": {
          "<name>": "<test parameter>"
        },
        "Outputs": {
        }
      }
      """
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <test target>/<name>/cloudformation/main.json and content matching
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
        },
        "Resources": {
          "<name>": "<test parameter>"
        },
        "Outputs": {
        }
      }
      """
    And the cloudformation stack should be created with name <prefix>-<name>-<test target>, template url https://s3.amazonaws.com/<bucket>/<test target>/<name>/cloudformation/main.json
    Examples:
      | prefix | name | test target | test parameter | production target | production parameter | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1 | production_1 | production_param_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2 | production_2 | production_param_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: update an existing CloudFormation stack
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
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    And the CloudFormation stack already exists
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And the cloudformation template should be validated with content matching cloudformation/main.json
    And the cloudformation template should be uploaded to S3 bucket <bucket> with key <target>/<name>/cloudformation/main.json and content matching cloudformation/main.json
    And the cloudformation stack should be updated with name <prefix>-<name>-<target>, template url https://s3.amazonaws.com/<bucket>/<target>/<name>/cloudformation/main.json
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: deploy a CloudFormation stack with child stacks
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
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "test",
        "Parameters": {
          "formatronS3Bucket": {
            "Type": "String"
          },
          "formatronCloudformationS3Key": {
            "Type": "String"
          }
        },
        "Resources": {
          "child1": {
             "Type" : "AWS::CloudFormation::Stack",
             "Properties" : {
               "TemplateURL" : { "Fn::Join": [ "", [ "https://s3.amazonaws.com/", { "Ref": "formatronS3Bucket" }, "/", { "Ref": "formatronCloudformationS3Key" }, "/child1.json" ] ] }
             }
          },
          "child2": {
             "Type" : "AWS::CloudFormation::Stack",
             "Properties" : {
               "TemplateURL" : { "Fn::Join": [ "", [ "https://s3.amazonaws.com/", { "Ref": "formatronS3Bucket" }, "/", { "Ref": "formatronCloudformationS3Key" }, "/child2.json" ] ] }
             }
          }
        },
        "Outputs": {
        }
      }
      """
    And a cloudformation/child1.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "child1",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    And a cloudformation/child2.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "child2",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    When  I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with AWS
    And a cloudformation template should be validated with content matching cloudformation/main.json
    And a cloudformation template should be validated with content matching cloudformation/child1.json
    And a cloudformation template should be validated with content matching cloudformation/child2.json
    And a cloudformation template should be uploaded to S3 bucket <bucket> with key <target>/<name>/cloudformation/child1.json and content matching cloudformation/child1.json
    And a cloudformation template should be uploaded to S3 bucket <bucket> with key <target>/<name>/cloudformation/child2.json and content matching cloudformation/child2.json
    And the cloudformation stack should be created with name <prefix>-<name>-<target>, template url https://s3.amazonaws.com/<bucket>/<target>/<name>/cloudformation/main.json and parameters
      | parameter | value |
      | formatronS3Bucket | <bucket> |
      | formatronCloudformationS3Key | <target>/<name>/cloudformation |
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |
