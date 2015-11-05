require 'spec_helper'
require 'formatron/formatronfile/bootstrap/vpc'

class Formatron
  class Formatronfile
    # namespacing for tests
    class Bootstrap
      describe VPC do
        before(:each) do
          @vpc = VPC.new
        end

        describe '#cidr' do
          it 'should set the VPC CIDR' do
            expect(@vpc.cidr).to be_nil
            @vpc.cidr '1'
            expect(@vpc.cidr).to eql '1'
          end
        end

        describe '#subnet' do
          before :each do
            @subnet1 = double
            allow(@subnet1).to receive :test
            @subnet2 = double
            allow(@subnet2).to receive :test
            @subnets = {
              'subnet1' => @subnet1,
              'subnet2' => @subnet2
            }
            subnet_class = class_double(
              'Formatron::Formatronfile::Bootstrap' \
              '::VPC::Subnet'
            ).as_stubbed_const
            @subnets.each do |key, subnet|
              allow(subnet_class).to receive(:new) { subnet }
              @vpc.subnet key do |s|
                s.test
              end
            end
          end

          it 'should add a subnet configuration and ' \
              'yield to the subnet block' do
            expect(@vpc.subnets).to eql @subnets
            expect(@subnet1).to have_received(:test).once.with no_args
            expect(@subnet2).to have_received(:test).once.with no_args
          end
        end
      end
    end
  end
end
