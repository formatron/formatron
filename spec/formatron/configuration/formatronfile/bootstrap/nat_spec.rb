require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/nat'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe NAT do
          before(:each) do
            @nat = NAT.new
          end

          describe '#subnet' do
            it 'should set the subnet name' do
              expect(@nat.subnet).to be_nil
              @nat.subnet 'subnet'
              expect(@nat.subnet).to eql 'subnet'
            end
          end

          describe '#sub_domain' do
            it 'should set the sub domain' do
              expect(@nat.sub_domain).to be_nil
              @nat.sub_domain 'sub_domain'
              expect(@nat.sub_domain).to eql 'sub_domain'
            end
          end

          describe '#instance_cookbook' do
            it 'should set the instance coobook name' do
              expect(@nat.instance_cookbook).to be_nil
              @nat.instance_cookbook 'instance_cookbook'
              expect(@nat.instance_cookbook).to eql 'instance_cookbook'
            end
          end
        end
      end
    end
  end
end
