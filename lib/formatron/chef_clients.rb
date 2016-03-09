class Formatron
  # creates chef clients
  class ChefClients
    # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def initialize(
      directory:,
      aws:,
      bucket:,
      name:,
      target:,
      ec2_key:,
      hosted_zone_name:,
      vpc:,
      external:,
      configuration:,
      databag_secret:
    )
      @chef_clients = {}
      if external.nil?
        bastions = Util::VPC.instances :bastion, vpc
        chef_servers = Util::VPC.instances :chef_server, vpc
      else
        bastions = Util::VPC.instances :bastion, external, vpc
        chef_servers = Util::VPC.instances :chef_server, external, vpc
      end
      bastions = Hash[bastions.map { |k, v| [k, v.sub_domain] }]
      chef_servers.each do |key, chef_server|
        @chef_clients[key] = Chef.new(
          directory: directory,
          aws: aws,
          bucket: bucket,
          name: name,
          target: target,
          username: chef_server.username,
          organization: chef_server.organization.short_name,
          ssl_verify: chef_server.ssl_verify,
          chef_sub_domain: chef_server.sub_domain,
          ec2_key: ec2_key,
          bastions: bastions,
          hosted_zone_name: hosted_zone_name,
          server_stack: chef_server.stack || name,
          guid: chef_server.guid,
          configuration: configuration,
          databag_secret: databag_secret
        )
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/ParameterLists

    def get(key = nil)
      key ||= @chef_clients.keys[0]
      @chef_clients[key]
    end

    def init
      @chef_clients.values.each(&:init)
    end
  end
end
