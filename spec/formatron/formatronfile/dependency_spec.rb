require 'spec_helper'
require 'formatron/formatronfile/dependency_spec'

class Formatron
  # namespacing for tests
  class Formatronfile
    describe Dependency do
      bucket = 'bucket'
      target = 'target'
      name = 'name'

      before :each do
        @aws = instance_double 'Formatron::AWS'
        @dependency = Dependency.new(
          aws: @aws,
          bucket: bucket,
          target: target,
          name: name
        )
      end

      describe '#name' do
        it 'should return the name of the dependency' do
          expect(@dependency.name).to eql name
        end
      end
    end
  end
end
