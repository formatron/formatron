Feature: Opscode Chef Server support
  In order to configure EC2 instances without OpsWorks so that instance IDs and IP addresses can be known as the CloudFormation stack is deployed
  As a maintainer of formatron stacks
  I want to be able to deploy a Chef Server and Chef Nodes as part of a CloudFormation stack

  Rules:
  - A special case should be supported to deploy a Chef Server where the cookbooks are vendored to S3 so that they can be used during cloudformation init and the server added as a node to itself on first run
  - The initial users Chef Server keys should be securely made available for use by other stacks
  - Node cookbooks should be uploaded to the Chef Server using environments to pin the versions
  - Nodes should be bootstrapped from the chef server on CloudFormation stack deployment

  Scenario Outline: initially deploy a Chef Server
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
      opscode do
        server_url config['<name>']['url']
        ssl_verify config['<name>']['sslVerify']
        user config['<name>']['user']
        organization config['<name>']['organization']
        deploys_chef_server true
      end
      """
    And a config/_default/_default.json file with content
      """
      {
        "url": "https://my.chef.server",
        "sslVerify": true,
        "user": "administrator",
        "organization": "my_organization"
      }
      """
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "chef server",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    And an opscode/chef_server_node/metadata.rb file with content
      """
      name 'chef_server_node'
      """
    When I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the following cookbooks should have been vendored to the given directories
      | cookbook | directory | with lockfile |
      | opscode/chef_server_node | vendor/chef_server_node | true |
    And the following vendored cookbooks should be tarballed and uploaded to S3 bucket <bucket> with the given keys
      | vendored cookbook | S3 key |
      | vendor/chef_server_node | <target>/<name>/opscode/cookbooks/chef_server_node.tar.gz |
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 |

  Scenario Outline: update a Chef Server
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
      opscode do
        server_url config['<name>']['url']
        ssl_verify config['<name>']['sslVerify']
        user config['<name>']['user']
        organization config['<name>']['organization']
        deploys_chef_server true
      end
      """
    And a config/_default/_default.json file with content
      """
      {
        "url": "<chef server url>",
        "sslVerify": <ssl verify>,
        "user": "<user>",
        "organization": "<organization>"
      }
      """
    And a cloudformation/main.json file with content
      """
      {
        "AWSTemplateFormatVersion": "2010-09-09",
        "Description": "chef server",
        "Parameters": {
        },
        "Resources": {
        },
        "Outputs": {
        }
      }
      """
    And an opscode/chef_server_node/metadata.rb file with content
      """
      name 'chef_server_node'
      """
    And an already deployed Formatron stack called <name>
    And a <target>/<name>/opscode/keys/<user>.pem S3 key with content
      """
      <user key>
      """
    When I deploy the formatron stack with target <target>
    Then the region <region>, AWS access key ID <AWS access key ID> and AWS secret access key <AWS secret access key> should be used when communicating with S3
    And the url <chef server url>, user <user>, user key <user key>, organization <organization> and the ssl verify flag <ssl verify> should be used to communicate with the Chef Server
    And an environment called <name>__chef_server_node should be created on the Chef Server
    And the cookbooks for the <name>__chef_server_node should be pinned from the opscode/chef_server_node cookbook
    Examples:
      | prefix | name | target | bucket | region | KMS key | AWS access key ID | AWS secret access key | chef server url | ssl verify | user | user key | organization |
      | my_prefix_1 | my_stack_1 | test_1 | my_bucket_1 | my_region_1 | my_test_kms_key_1 | access_key_id_1 | secret_access_key_1 | https://chef1.server.com | true | user_1 | user_key_1 | organization_1 |
      | my_prefix_2 | my_stack_2 | test_2 | my_bucket_2 | my_region_2 | my_test_kms_key_2 | access_key_id_2 | secret_access_key_2 | https://chef2.server.com | false | user_2 | user_key_2 | organization_2 |
