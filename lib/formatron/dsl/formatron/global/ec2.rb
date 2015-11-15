require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class Global
        # EC2 key pair configuration
        class EC2
          extend Util::DSL

          attr_reader :external

          dsl_initialize_block do |external:|
            @external = external
          end

          dsl_property :key_pair
          dsl_property :private_key
        end
      end
    end
  end
end
