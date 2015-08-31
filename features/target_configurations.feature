Feature: Target configurations
  In order to test a formatron stack definition without affecting production resources
  As a maintainer of formatron stacks
  I want to be able to deploy separate target configurations from the same definition

  Rules:
  - CloudFormation stacks should be properly namespaced
  - Configuration should be loaded from target specific sources
  - Target specific S3 keys should be properly namespaced

  Scenario Outline: deploy
    Given a basic formatron stack definition
    And a prefix of <prefix>
    And a name of <name>
    And a test target name of <test target>
    And a test configuration parameter of <test parameter>
    And a production target name of <production target>
    And a production configuration parameter of <production parameter>
    And an S3 bucket of <bucket>
    When  I deploy the formatron stack with target <test target>
    Then the cloudformation stack should be called <cloudformation stack>
    And the cloudformation parameter should be <test parameter>
    And the S3 key for the cloudformation template should be <cloudformation S3 key>

    Examples:
      | prefix      | name       | test target | test parameter | production target | production parameter | bucket      | cloudformation stack | cloudformation S3 key|
      | my_prefix_1 | my_stack_1 | test_1 | test_param_1 | production_1 | production_param_1 | my_bucket_1 | my_prefix_1-my_stack_1-test_1 | my_bucket_1/test_1/my_stack_1/cloudformation/main.json |
      | my_prefix_2 | my_stack_2 | test_2 | test_param_2 | production_2 | production_param_2 | my_bucket_2 | my_prefix_2-my_stack_2-test_2 | my_bucket_2/test_2/my_stack_2/cloudformation/main.json |
