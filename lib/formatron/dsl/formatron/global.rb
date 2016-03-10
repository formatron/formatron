require 'formatron/util/dsl'
require_relative 'global/ec2'
require_relative 'global/windows'

class Formatron
  class DSL
    class Formatron
      # Global configuration
      class Global
        extend Util::DSL

        attr_reader :hosted_zone_name

        dsl_initialize_block do |aws:|
          @aws = aws
        end

        dsl_property :protect
        dsl_property :kms_key
        dsl_property :databag_secret
        dsl_block :ec2, 'EC2'
        dsl_block :windows, 'Windows'

        def hosted_zone_id(value = nil)
          unless value.nil?
            @hosted_zone_id = value
            @hosted_zone_name = @aws.hosted_zone_name value
          end
          @hosted_zone_id
        end
      end
    end
  end
end
