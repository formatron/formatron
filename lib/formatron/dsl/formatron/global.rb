require 'formatron/util/dsl'
require_relative 'global/ec2'

class Formatron
  class DSL
    class Formatron
      # Global configuration
      class Global
        extend Util::DSL

        attr_reader :external

        dsl_initialize_block do |external:|
          @external = external
          @external_ec2 = external.ec2
        end

        dsl_property :protect
        dsl_property :kms_key
        dsl_property :hosted_zone_id
        dsl_block :ec2, 'EC2' do
          { external: @external_ec2 }
        end
      end
    end
  end
end
