require 'spec_helper'
require 'formatron/dsl/formatron/vpc/subnet/chef_server'

class Formatron
  class DSL
    class Formatron
      class VPC
        # namespacing for tests
        class Subnet
          describe ChefServer do
            extend DSLTest
            dsl_before_hash
            it 'should be an Instance' do
              expect(@dsl_instance).to be_an Instance
            end
            dsl_property :version
            dsl_property :cookbooks_bucket
            dsl_property :username
            dsl_property :email
            dsl_property :first_name
            dsl_property :last_name
            dsl_property :password
            dsl_property :ssl_key
            dsl_property :ssl_cert
            dsl_property :ssl_verify
            dsl_block :organization, 'Organization'
          end
        end
      end
    end
  end
end
