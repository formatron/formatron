require 'formatron/chef_clients'

# rubocop:disable Metrics/ClassLength
class Formatron
  describe ChefClients do
    before :each do
      @aws = 'aws'
      @bucket = 'bucket'
      @name = 'name'
      @configuration = 'configuration'
      @databag_secret = 'databag_secret'
      @target = 'target'
      @ec2_key = 'ec2_key'
      @hosted_zone_name = 'hosted_zone_name'
      (@bastions, bastion_sub_domains) =
        (0..9).each_with_object([{}, {}]) do |i, (b, bs)|
          bastion = instance_double(
            'Formatron::DSL::Formatron::VPC::Subnet::Bastion'
          )
          key = "bastion#{i}"
          sub_domain = "bastion_sub_domain#{i}"
          allow(bastion).to receive(:sub_domain) { sub_domain }
          b[key] = bastion
          bs[key] = sub_domain
        end
      @vpc = instance_double 'Formatron::DSL::Formatron::VPC'
      @vpc_util_class = class_double(
        'Formatron::Util::VPC'
      ).as_stubbed_const
      chef_class = class_double(
        'Formatron::Chef'
      ).as_stubbed_const
      @chef_client = {}
      @chef_servers = (0..9).each_with_object({}) do |i, o|
        key = "chef#{i}"
        chef_server = instance_double(
          'Formatron::DSL::Formatron::VPC::Subnet::ChefServer'
        )
        username = "username#{i}"
        short_name = "short_name#{i}"
        ssl_verify = "ssl_verify#{i}"
        sub_domain = "sub_domain#{i}"
        guid = "guid#{i}"
        allow(chef_server).to receive(:username) { username }
        organization = instance_double(
          'Formatron::DSL::Formatron::VPC::Subnet::ChefServer::Organization'
        )
        allow(chef_server).to receive(:organization) { organization }
        allow(organization).to receive(:short_name) { short_name }
        allow(chef_server).to receive(:ssl_verify) { ssl_verify }
        allow(chef_server).to receive(:sub_domain) { sub_domain }
        allow(chef_server).to receive(:guid) { guid }
        allow(chef_server).to receive(:stack) { nil }
        chef_client = @chef_client[key] = instance_double(
          'Formatron::Chef'
        )
        allow(chef_client).to receive :init
        allow(chef_client).to receive :unlink
        allow(chef_class).to receive(:new).with(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          username: username,
          organization: short_name,
          ssl_verify: ssl_verify,
          chef_sub_domain: sub_domain,
          ec2_key: @ec2_key,
          bastions: bastion_sub_domains,
          hosted_zone_name: @hosted_zone_name,
          server_stack: @name,
          guid: guid,
          configuration: @configuration,
          databag_secret: @databag_secret
        ) { chef_client }
        o[key] = chef_server
      end
      (0..9).each_with_object(@chef_servers) do |i, o|
        key = "chef_with_stack#{i}"
        chef_server = instance_double(
          'Formatron::DSL::Formatron::VPC::Subnet::ChefServer'
        )
        username = "username#{i}"
        short_name = "short_name#{i}"
        ssl_verify = "ssl_verify#{i}"
        sub_domain = "sub_domain#{i}"
        guid = "guid#{i}"
        stack_name = "stack_name#{i}"
        allow(chef_server).to receive(:username) { username }
        organization = instance_double(
          'Formatron::DSL::Formatron::VPC::Subnet::ChefServer::Organization'
        )
        allow(chef_server).to receive(:organization) { organization }
        allow(organization).to receive(:short_name) { short_name }
        allow(chef_server).to receive(:ssl_verify) { ssl_verify }
        allow(chef_server).to receive(:sub_domain) { sub_domain }
        allow(chef_server).to receive(:guid) { guid }
        allow(chef_server).to receive(:stack) { stack_name }
        chef_client = @chef_client[key] = instance_double(
          'Formatron::Chef'
        )
        allow(chef_client).to receive :init
        allow(chef_client).to receive :unlink
        allow(chef_class).to receive(:new).with(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          username: username,
          organization: short_name,
          ssl_verify: ssl_verify,
          chef_sub_domain: sub_domain,
          ec2_key: @ec2_key,
          bastions: bastion_sub_domains,
          hosted_zone_name: @hosted_zone_name,
          server_stack: stack_name,
          guid: guid,
          configuration: @configuration,
          databag_secret: @databag_secret
        ) { chef_client }
        o[key] = chef_server
      end
    end

    context 'with a corresponding external VPC' do
      before :each do
        external = instance_double 'Formatron::DSL::Formatron::VPC'
        allow(@vpc_util_class).to receive(:instances).with(
          :bastion,
          external,
          @vpc
        ) { @bastions }
        allow(@vpc_util_class).to receive(:instances).with(
          :chef_server,
          external,
          @vpc
        ) { @chef_servers }
        @chef_clients = ChefClients.new(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          ec2_key: @ec2_key,
          hosted_zone_name: @hosted_zone_name,
          vpc: @vpc,
          external: external,
          configuration: @configuration,
          databag_secret: @databag_secret
        )
      end

      describe '#init' do
        it 'should init the chef clients' do
          @chef_clients.init
          @chef_client.values.each do |chef_client|
            expect(chef_client).to have_received :init
          end
        end
      end

      describe '#unlink' do
        it 'should unlink the chef clients' do
          @chef_clients.unlink
          @chef_client.values.each do |chef_client|
            expect(chef_client).to have_received :unlink
          end
        end
      end

      describe '#get' do
        it 'should return the corresponding Chef client' do
          @chef_client.keys.each do |k|
            expect(@chef_clients.get(k)).to eql @chef_client[k]
          end
        end

        context 'with nil' do
          it 'should return the first chef client' do
            expect(@chef_clients.get).to eql @chef_client.values[0]
          end
        end
      end
    end

    context 'without a corresponding external VPC' do
      before :each do
        allow(@vpc_util_class).to receive(:instances).with(
          :bastion,
          @vpc
        ) { @bastions }
        allow(@vpc_util_class).to receive(:instances).with(
          :chef_server,
          @vpc
        ) { @chef_servers }
        @chef_clients = ChefClients.new(
          aws: @aws,
          bucket: @bucket,
          name: @name,
          target: @target,
          ec2_key: @ec2_key,
          hosted_zone_name: @hosted_zone_name,
          vpc: @vpc,
          external: nil,
          configuration: @configuration,
          databag_secret: @databag_secret
        )
      end

      describe '#get' do
        it 'should return the corresponding Chef client' do
          @chef_servers.keys.each do |k|
            expect(@chef_clients.get(k)).to eql @chef_client[k]
          end
        end

        context 'with nil' do
          it 'should return the first chef client' do
            expect(@chef_clients.get).to eql @chef_client.values[0]
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
