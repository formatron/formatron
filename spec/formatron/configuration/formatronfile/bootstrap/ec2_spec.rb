require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/ec2'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe EC2 do
          before(:each) do
            @ec2 = EC2.new
          end

          describe '#key_pair' do
            it 'should set the EC2 key pair name' do
              expect(@ec2.key_pair).to be_nil
              @ec2.key_pair 'key_pair'
              expect(@ec2.key_pair).to eql 'key_pair'
            end
          end

          describe '#private_key' do
            it 'should set the location of the private key file' do
              expect(@ec2.private_key).to be_nil
              @ec2.private_key 'private_key'
              expect(@ec2.private_key).to eql 'private_key'
            end
          end
        end
      end
    end
  end
end
