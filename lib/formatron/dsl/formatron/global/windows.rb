require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      class Global
        # Windows authentication parameters
        class Windows
          extend Util::DSL
          dsl_initialize_block
          dsl_property :administrator_name
          dsl_property :administrator_password
        end
      end
    end
  end
end
