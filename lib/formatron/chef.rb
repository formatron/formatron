require 'formatron/cloud_formation'
require_relative 'chef/keys'
require_relative 'chef/berkshelf'
require_relative 'chef/knife'

class Formatron
  # manage the instance provisioning with Chef
  class Chef
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    def initialize(
      aws:,
      bucket:,
      name:,
      target:,
      private_key:,
      username:,
      organization:,
      ssl_verify:,
      chef_sub_domain:,
      bastion_sub_domain:,
      hosted_zone_name:,
      server_stack:
    )
      @aws = aws
      @name = name
      @target = target
      @private_key = private_key
      @chef_sub_domain = chef_sub_domain
      @hosted_zone_name = hosted_zone_name
      @organization = organization
      chef_server_url = _chef_server_url
      @bastion_hostname = _hostname(
        sub_domain: bastion_sub_domain
      )
      CloudFormation.stack_ready!(
        aws: @aws,
        name: server_stack,
        target: @target
      )
      @keys = Keys.new(
        aws: @aws,
        bucket: bucket,
        name: server_stack,
        target: @target
      )
      @knife = Knife.new(
        keys: @keys,
        chef_server_url: chef_server_url,
        username: username,
        organization: organization,
        ssl_verify: ssl_verify
      )
      @berkshelf = Berkshelf.new(
        keys: @keys,
        chef_server_url: chef_server_url,
        username: username,
        ssl_verify: ssl_verify
      )
    end
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def provision(
      sub_domain:,
      cookbook:
    )
      CloudFormation.stack_ready!(
        aws: @aws,
        name: @name,
        target: @target
      )
      cookbook_name = File.basename cookbook
      hostname = _hostname(
        sub_domain: sub_domain
      )
      @knife.create_environment environment: sub_domain
      @berkshelf.upload environment: sub_domain, cookbook: cookbook
      @knife.bootstrap(
        bastion_hostname: @bastion_hostname,
        environment: sub_domain,
        cookbook: cookbook_name,
        hostname: hostname,
        private_key: @private_key
      )
    end
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength

    def destroy(sub_domain:)
      @knife.delete_node node: sub_domain
      @knife.delete_client client: sub_domain
      @knife.delete_environment environment: sub_domain
    end

    def unlink
      @keys.unlink
      @knife.unlink
      @berkshelf.unlink
    end

    def _chef_server_url
      "https://#{@chef_sub_domain}.#{@hosted_zone_name}" \
      "/organizations/#{@organization}"
    end

    def _hostname(sub_domain:)
      "#{sub_domain}.#{@hosted_zone_name}"
    end

    private(
      :_chef_server_url,
      :_hostname
    )
  end
end
