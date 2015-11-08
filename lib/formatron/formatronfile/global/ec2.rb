require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    class Global
      # EC2 key pair configuration
      class EC2
        extend Util::DSL
        dsl_initialize_block
        dsl_property :key_pair
        dsl_property :private_key
      end
    end
  end
end
