require 'formatron/cloud_formation'
require_relative 'chef/keys'
require_relative 'chef/berkshelf'
require_relative 'chef/knife'

class Formatron
  # manage the instance provisioning with Chef
  module Chef
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/AbcSize
    def self.provision(
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
      instances:
    )
      chef_server_url = _chef_server_url(
        sub_domain: chef_sub_domain,
        hosted_zone_name: hosted_zone_name,
        organization: organization
      )
      bastion_hostname = _hostname(
        sub_domain: bastion_sub_domain,
        hosted_zone_name: hosted_zone_name
      )
      CloudFormation.stack_ready!(
        aws: aws,
        name: name,
        target: target
      )
      keys = Keys.new(
        aws: aws,
        bucket: bucket,
        name: name,
        target: target
      )
      knife = Knife.new(
        keys: keys,
        chef_server_url: chef_server_url,
        username: username,
        organization: organization,
        ssl_verify: ssl_verify
      )
      berkshelf = Berkshelf.new(
        keys: keys,
        chef_server_url: chef_server_url,
        username: username,
        ssl_verify: ssl_verify
      )
      instances.each do |instance|
        cookbook = instance.instance_cookbook
        cookbook_name = File.basename cookbook
        environment = _environment(
          name: name,
          cookbook: cookbook_name
        )
        hostname = _hostname(
          sub_domain: instance.sub_domain,
          hosted_zone_name: hosted_zone_name
        )
        knife.create_environment environment: environment
        berkshelf.upload environment: environment, cookbook: cookbook
        knife.bootstrap(
          bastion_hostname: bastion_hostname,
          environment: environment,
          cookbook: cookbook_name,
          hostname: hostname,
          private_key: private_key
        )
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength

    def self.destroy(aws:, configuration:, target:)
      puts aws
      puts configuration
      puts target
    end

    def self._chef_server_url(sub_domain:, hosted_zone_name:, organization:)
      "https://#{sub_domain}.#{hosted_zone_name}" \
      "/organizations/#{organization}"
    end

    def self._environment(name:, cookbook:)
      "#{name}__#{cookbook}"
    end

    def self._hostname(sub_domain:, hosted_zone_name:)
      "#{sub_domain}.#{hosted_zone_name}"
    end

    private_class_method(
      :_chef_server_url
    )
  end
end
