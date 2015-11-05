require 'spec_helper'
require 'formatron/formatronfile/instance'

class Formatron
  # namespacing for tests
  class Formatronfile
    describe Instance do
      before(:each) do
        @instance = Instance.new
      end

      describe '#subnet' do
        it 'should set the subnet name' do
          expect(@instance.subnet).to be_nil
          @instance.subnet 'subnet'
          expect(@instance.subnet).to eql 'subnet'
        end
      end

      describe '#sub_domain' do
        it 'should set the sub domain' do
          expect(@instance.sub_domain).to be_nil
          @instance.sub_domain 'sub_domain'
          expect(@instance.sub_domain).to eql 'sub_domain'
        end
      end

      describe '#instance_cookbook' do
        it 'should set the instance coobook name' do
          expect(@instance.instance_cookbook).to be_nil
          @instance.instance_cookbook 'instance_cookbook'
          expect(@instance.instance_cookbook).to eql 'instance_cookbook'
        end
      end
    end
  end
end
