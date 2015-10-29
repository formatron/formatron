require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/bastion'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe Bastion do
          before(:each) do
            @bastion = Bastion.new
          end

          describe '#subnet' do
            it 'should set the subnet name' do
              expect(@bastion.subnet).to be_nil
              @bastion.subnet 'subnet'
              expect(@bastion.subnet).to eql 'subnet'
            end
          end

          describe '#sub_domain' do
            it 'should set the sub domain' do
              expect(@bastion.sub_domain).to be_nil
              @bastion.sub_domain 'sub_domain'
              expect(@bastion.sub_domain).to eql 'sub_domain'
            end
          end

          describe '#instance_cookbook' do
            it 'should set the instance coobook name' do
              expect(@bastion.instance_cookbook).to be_nil
              @bastion.instance_cookbook 'instance_cookbook'
              expect(@bastion.instance_cookbook).to eql 'instance_cookbook'
            end
          end
        end
      end
    end
  end
end
