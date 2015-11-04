require 'spec_helper'
require 'formatron/chef'

# namespacing for tests
# rubocop:disable Metrics/ClassLength
class Formatron
  describe Chef do
    describe '::provision' do
      before :each do
        @aws = instance_double 'Formatron::AWS'
        @configuration = instance_double 'Formatron::Configuration'
        @target = 'target'
        @name = 'name'
        @bucket = 'bucket'
        @chef_sub_domain = 'chef_sub_domain'
        @hosted_zone_name = 'hosted_zone_name'
        @organization = 'organization'
        @username = 'username'
        @ssl_verify = 'ssl_verify'
        @private_key = 'private_key'
        @bastion_cookbook = 'bastion_cookbook'
        @bastion_sub_domain = 'bastion_sub_domain'
        @bastion_environment = "#{@name}__#{@bastion_cookbook}"
        @bastion_hostname = "#{@bastion_sub_domain}.#{@hosted_zone_name}"
        @chef_server_url = "https://#{@chef_sub_domain}.#{@hosted_zone_name}" \
                           "/organizations/#{@organization}"
        @cloud_formation_stack = class_double(
          'Formatron::CloudFormationStack'
        ).as_stubbed_const
        allow(@configuration).to receive(:name).with(
          @target
        ) { @name }
        allow(@configuration).to receive(:bucket).with(
          @target
        ) { @bucket }
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
          expect(@cloud_formation_stack).to receive(:stack_ready!).once.with(
            aws: @aws,
            name: @name,
            target: @target
          ) { fail 'not ready' }
        end

        it 'should error' do
          expect do
            Chef.provision(
              aws: @aws,
              configuration: @configuration,
              target: @target
            )
          end.to raise_error 'not ready'
        end
      end

      context 'when the CloudFormation stack is ready' do
        before :each do
          expect(@cloud_formation_stack).to receive(:stack_ready!).once.with(
            aws: @aws,
            name: @name,
            target: @target
          )
          Chef.provision(
            aws: @aws,
            configuration: @configuration,
            target: @target
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
            organization: @organization,
            ssl_verify: @ssl_verify
          )
        end

        it 'should create the bastion environment' do
          expect(@knife).to receive(:create_environment).once.with(
            environment: @bastion_environment
          )
        end

        it 'should deploy the bastion cookbooks' do
          expect(@berkshelf).to have_received(:upload).once.with(
            environment: @bastion_environment,
            cookbook: @bastion_cookbook
          )
        end

        it 'should bootstrap the bastion instance' do
          expect(@knife).to receive(:bootstrap).once.with(
            environment: @bastion_environment,
            cookbook: @bastion_cookbook,
            hostname: @bastion_hostname,
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
