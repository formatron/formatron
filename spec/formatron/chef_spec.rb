require 'spec_helper'
require 'formatron/chef'

# namespacing for tests
# rubocop:disable Metrics/ClassLength
class Formatron
  describe Chef do
    describe '::provision' do
      before :each do
        @aws = instance_double 'Formatron::AWS'
        @name = 'name'
        @hosted_zone_name = 'hosted_zone_name'
        @instance0 = instance_double 'Formatron::Formatronfile::Instance'
        @instance0_cookbook = 'instance0_cookbook'
        @instance0_sub_domain = 'instance0_sub_domain'
        allow(@instance0).to receive(:instance_cookbook) { @instance0_cookbook }
        allow(@instance0).to receive(
          :sub_domain
        ) { @instance0_sub_domain }
        @instance0_environment = "#{@name}__#{@instance0_cookbook}"
        @instance0_hostname = "#{@instance0_sub_domain}.#{@hosted_zone_name}"
        @instance1 = instance_double 'Formatron::Formatronfile::Instance'
        @instance1_cookbook = 'instance1_cookbook'
        @instance1_sub_domain = 'instance1_sub_domain'
        allow(@instance1).to receive(:instance_cookbook) { @instance1_cookbook }
        allow(@instance1).to receive(
          :sub_domain
        ) { @instance1_sub_domain }
        @instance1_environment = "#{@name}__#{@instance1_cookbook}"
        @instance1_hostname = "#{@instance1_sub_domain}.#{@hosted_zone_name}"
        @bastion_sub_domain = 'bastion_sub_domain'
        @bastion_hostname = "#{@bastion_sub_domain}.#{@hosted_zone_name}"
        @instances = [
          @instance0,
          @instance1
        ]
        @target = 'target'
        @bucket = 'bucket'
        @chef_sub_domain = 'chef_sub_domain'
        @organization = 'organization'
        @username = 'username'
        @ssl_verify = 'ssl_verify'
        @private_key = 'private_key'
        @chef_server_url = "https://#{@chef_sub_domain}.#{@hosted_zone_name}" \
                           "/organizations/#{@organization}"
        @cloud_formation = class_double(
          'Formatron::CloudFormation'
        ).as_stubbed_const
        @keys_class = class_double(
          'Formatron::Chef::Keys'
        ).as_stubbed_const
        @keys = instance_double 'Formatron::Chef::Keys'
        allow(@keys_class).to receive(:new) { @keys }
        @berkshelf_class = class_double(
          'Formatron::Chef::Berkshelf'
        ).as_stubbed_const
        @berkshelf = instance_double 'Formatron::Chef::Berkshelf'
        allow(@berkshelf_class).to receive(:new) { @berkshelf }
        allow(@berkshelf).to receive(:upload)
        @knife_class = class_double(
          'Formatron::Chef::Knife'
        ).as_stubbed_const
        @knife = instance_double 'Formatron::Chef::Knife'
        allow(@knife_class).to receive(:new) { @knife }
        allow(@knife).to receive(:create_environment)
        allow(@knife).to receive(:bootstrap)
      end

      context 'when the CloudFormation stack is not ready' do
        before :each do
          expect(@cloud_formation).to receive(:stack_ready!).once.with(
            aws: @aws,
            name: @name,
            target: @target
          ) { fail 'not ready' }
        end

        it 'should error' do
          expect do
            Chef.provision(
              aws: @aws,
              bucket: @bucket,
              name: @name,
              target: @target,
              private_key: @private_key,
              username: @username,
              organization: @organization,
              ssl_verify: @ssl_verify,
              chef_sub_domain: @chef_sub_domain,
              bastion_sub_domain: @bastion_sub_domain,
              hosted_zone_name: @hosted_zone_name,
              instances: @instances
            )
          end.to raise_error 'not ready'
        end
      end

      context 'when the CloudFormation stack is ready' do
        before :each do
          expect(@cloud_formation).to receive(:stack_ready!).once.with(
            aws: @aws,
            name: @name,
            target: @target
          )
          Chef.provision(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target,
            private_key: @private_key,
            username: @username,
            organization: @organization,
            ssl_verify: @ssl_verify,
            chef_sub_domain: @chef_sub_domain,
            bastion_sub_domain: @bastion_sub_domain,
            hosted_zone_name: @hosted_zone_name,
            instances: @instances
          )
        end

        it 'should download the chef keys' do
          expect(@keys_class).to have_received(:new).once.with(
            aws: @aws,
            bucket: @bucket,
            name: @name,
            target: @target
          )
        end

        it 'should create a knife client' do
          expect(@knife_class).to receive(:new).once.with(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            organization: @organization,
            ssl_verify: @ssl_verify
          )
        end

        it 'should create a berkshelf client' do
          expect(@berkshelf_class).to receive(:new).once.with(
            keys: @keys,
            chef_server_url: @chef_server_url,
            username: @username,
            ssl_verify: @ssl_verify
          )
        end

        it 'should create the instance environments' do
          expect(@knife).to receive(:create_environment).once.with(
            environment: @instance0_environment
          )
          expect(@knife).to receive(:create_environment).once.with(
            environment: @instance1_environment
          )
        end

        it 'should deploy the instance cookbooks' do
          expect(@berkshelf).to have_received(:upload).once.with(
            environment: @instance0_environment,
            cookbook: @instance0_cookbook
          )
          expect(@berkshelf).to have_received(:upload).once.with(
            environment: @instance1_environment,
            cookbook: @instance1_cookbook
          )
        end

        it 'should bootstrap the instances' do
          expect(@knife).to receive(:bootstrap).once.with(
            bastion_hostname: @bastion_hostname,
            environment: @instance0_environment,
            cookbook: @instance0_cookbook,
            hostname: @instance0_hostname,
            private_key: @private_key
          )
          expect(@knife).to receive(:bootstrap).once.with(
            bastion_hostname: @bastion_hostname,
            environment: @instance1_environment,
            cookbook: @instance1_cookbook,
            hostname: @instance1_hostname,
            private_key: @private_key
          )
        end
      end
    end

    describe '::destroy' do
      it 'should do something' do
        Chef.destroy(
          aws: @aws,
          configuration: @configuration,
          target: @target
        )
      end

      skip 'should do something useful'
    end
  end
end
# rubocop:enable Metrics/ClassLength
