require 'spec_helper'

require 'formatron/configuration'
require 'formatron/generators/bootstrap'

describe Formatron::Configuration do
  include FakeFS::SpecHelpers

  directory = 'test/directory'
  credentials = 'test/credentials'
  region = 'region'
  access_key_id = 'access_key_id'
  secret_access_key = 'secret_access_key'

  before(:each) do
    lib = File.expand_path(
      File.join(
        File.dirname(File.expand_path(__FILE__)),
        '../../lib'
      )
    )
    FakeFS::FileSystem.clone lib
  end

  context 'with a bootstrap configuration' do
    params = {
      name: 'bootstrap',
      hosted_zone_id: 'HOSTEDZONEID',
      kms_key: 'KMSKEY',
      ec2_key_pair: 'ec2-key-pair',
      availability_zone: 'a',
      s3_bucket: 'my_s3_bucket',
      chef_server: {
        organization: 'my_organization',
        username: 'my_username',
        email: 'my_email',
        first_name: 'my_first_name',
        last_name: 'my_last_name',
        password: 'password'
      },
      targets: {
        target1: {
          protect: true
        },
        target2: {
          protect: false
        }
      }
    }

    before(:each) do
      Formatron::Generators::Bootstrap.generate(
        directory,
        params
      )
      Formatron::Generators::Credentials.generate(
        credentials,
        region,
        access_key_id,
        secret_access_key
      )
      @configuration = Formatron::Configuration.new(
        credentials,
        directory
      )
    end

    describe '::deploy' do
      before(:each) do
        @configuration.deploy 'target1'
      end

      skip 'should upload the configuration to S3' do
      end
    end
  end
end
