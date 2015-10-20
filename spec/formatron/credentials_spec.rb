require 'spec_helper'

require 'formatron/generators/credentials'

describe Formatron::Generators::Credentials do
  include FakeFS::SpecHelpers

  region = 'region'
  access_key_id = 'access_key_id'
  secret_access_key = 'secret_access_key'

  context "with an access key ID of #{access_key_id}, " \
          "secret access key of #{secret_access_key} and " \
          "region of #{region}" do
    describe '::generate' do
      it 'should generate the credentials JSON' do
        Formatron::Generators::Credentials.generate(
          'credentials.json',
          region,
          access_key_id,
          secret_access_key
        )
        actual = File.read 'credentials.json'
        expect(actual).to eql <<-EOH.gsub(/^ {10}/, '')
          {
            "region": "region",
            "access_key_id": "access_key_id",
            "secret_access_key": "secret_access_key"
          }
        EOH
      end
    end
  end
end
