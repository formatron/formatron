require 'spec_helper'
require 'formatron/dsl/formatron/global/windows'

class Formatron
  class DSL
    class Formatron
      # namespacing for tests
      class Global
        describe Windows do
          extend DSLTest
          dsl_before_block
          dsl_property :administrator_name
          dsl_property :administrator_password
        end
      end
    end
  end
end
