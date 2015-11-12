require 'spec_helper'
require 'formatron/dsl/formatron/dependency'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe Dependency do
        extend DSLTest
        dsl_before_hash [:aws]

        it 'should do something' do
        end
      end
    end
  end
end
