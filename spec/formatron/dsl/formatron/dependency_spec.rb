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
          @external = instance_double 'Formatron::External'
          { aws: @aws, external: @external }
        end

        it 'should do something' do
        end
      end
    end
  end
end
