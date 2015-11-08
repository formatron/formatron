require_relative 'chef_server/organization'
require_relative 'instance'
require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class VPC
      class Subnet
        #  Chef Server instance configuration
        class ChefServer < Instance
          extend Util::DSL
          dsl_initialize_hash
          dsl_property :version
          dsl_property :cookbooks_bucket
          dsl_property :organization
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
