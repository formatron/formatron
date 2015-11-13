require 'spec_helper'
require 'formatron/dsl/formatron/dependency'

class Formatron
  class DSL
    # namespacing for tests
    class Formatron
      describe Dependency do
        extend DSLTest
        dsl_before_hash do |_key|
          @aws = instance_double 'Formatron::AWS'
          { aws: @aws }
        end

        it 'should do something' do
        end
      end
    end
  end
end
