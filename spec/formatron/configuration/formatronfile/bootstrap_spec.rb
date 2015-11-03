require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap'

class Formatron
  class Configuration
    # namespacing for tests
    class Formatronfile
      describe Bootstrap do
        before(:each) do
          @bootstrap = Bootstrap.new
        end

        describe '#protect' do
          it 'should set whether the configuration should be ' \
             'protected from accidental deployment, etc' do
            expect(@bootstrap.protect).to be_nil
            @bootstrap.protect true
            expect(@bootstrap.protect).to eql true
          end
        end

        describe '#kms_key' do
          it 'should set the KMS key' do
            expect(@bootstrap.kms_key).to be_nil
            @bootstrap.kms_key 'kms_key'
            expect(@bootstrap.kms_key).to eql 'kms_key'
          end
        end

        describe '#hosted_zone_id' do
          it 'should set the Route53 public hosted zone ID' do
            expect(@bootstrap.hosted_zone_id).to be_nil
            @bootstrap.hosted_zone_id 'hosted_zone_id'
            expect(@bootstrap.hosted_zone_id).to eql 'hosted_zone_id'
          end
        end

        describe '#ec2' do
          before :each do
            @ec2 = double
            allow(Bootstrap::EC2).to receive(:new) { @ec2 }
            allow(@ec2).to receive :test
          end

          it 'should set the EC2 configuration and yield to the EC2 block' do
            @bootstrap.ec2(&:test)
            expect(@bootstrap.ec2).to eql @ec2
            expect(@ec2).to have_received(:test).once.with no_args
          end
        end

        describe '#vpc' do
          before :each do
            @vpc = double
            allow(Bootstrap::VPC).to receive(:new) { @vpc }
            allow(@vpc).to receive :test
          end

          it 'should set the VPC configuration and yield to the VPC block' do
            @bootstrap.vpc(&:test)
            expect(@bootstrap.vpc).to eql @vpc
            expect(@vpc).to have_received(:test).once.with no_args
          end
        end

        describe '#bastion' do
          before :each do
            @bastion = double
            allow(Instance).to receive(:new) { @bastion }
            allow(@bastion).to receive :test
          end

          it 'should set the bastion instance configuration and ' \
             'yield to the bastion block' do
            @bootstrap.bastion(&:test)
            expect(@bootstrap.bastion).to eql @bastion
            expect(@bastion).to have_received(:test).once.with no_args
          end
        end

        describe '#nat' do
          before :each do
            @nat = double
            allow(Instance).to receive(:new) { @nat }
            allow(@nat).to receive :test
          end

          it 'should set the NAT instance configuration and ' \
             'yield to the NAT block' do
            @bootstrap.nat(&:test)
            expect(@bootstrap.nat).to eql @nat
            expect(@nat).to have_received(:test).once.with no_args
          end
        end

        describe '#chef_server' do
          before :each do
            @chef_server = double
            allow(Bootstrap::ChefServer).to receive(:new) { @chef_server }
            allow(@chef_server).to receive :test
          end

          it 'should set the Chef Server instance configuration and ' \
             'yield to the Chef Server block' do
            @bootstrap.chef_server(&:test)
            expect(@bootstrap.chef_server).to eql @chef_server
            expect(@chef_server).to have_received(:test).once.with no_args
          end
        end
      end
    end
  end
end
