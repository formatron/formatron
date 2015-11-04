require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/vpc/subnet'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # namespacing for tests
        class VPC
          describe Subnet do
            before(:each) do
              @subnet = Subnet.new
            end

            describe '#availability_zone' do
              it 'should set the availability zone' do
                expect(@subnet.availability_zone).to be_nil
                @subnet.availability_zone 'a'
                expect(@subnet.availability_zone).to eql 'a'
              end
            end

            describe '#cidr' do
              it 'should set the subnet cidr' do
                expect(@subnet.cidr).to be_nil
                @subnet.cidr '1'
                expect(@subnet.cidr).to eql '1'
              end
            end

            describe '#public' do
              before :each do
                acl_class = class_double(
                  'Formatron::Configuration::Formatronfile' \
                  '::Bootstrap::VPC::Subnet::ACL'
                ).as_stubbed_const
                @acl = instance_double(
                  'Formatron::Configuration::Formatronfile' \
                  '::Bootstrap::VPC::Subnet::ACL'
                )
                allow(acl_class).to receive(:new) { @acl }
                allow(@acl).to receive :source_cidr
              end

              context 'when set to false' do
                before :each do
                  @subnet.public false do |acl|
                    acl.source_cidr '1'
                  end
                end

                it 'should set the ACL to nil and flag as not public' do
                  expect(@subnet.acl).to be_nil
                  expect(@subnet.public?).to eql false
                end

                it 'should ignore the ACL block' do
                  expect(@acl).to_not have_received :source_cidr
                end
              end

              context 'when set to true' do
                context 'with an ACL block' do
                  before :each do
                    @subnet.public true do |acl|
                      acl.source_cidr '1'
                    end
                  end

                  it 'should set the ACL and flag as public' do
                    expect(@subnet.acl).to eql @acl
                    expect(@subnet.public?).to eql true
                  end

                  it 'should yield to the ACL block' do
                    expect(@acl).to have_received(:source_cidr).once.with '1'
                  end
                end

                context 'without an ACL block' do
                  before :each do
                    @subnet.public true
                  end

                  it 'should set the ACL and flag as public' do
                    expect(@subnet.acl).to eql @acl
                    expect(@subnet.public?).to eql true
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
