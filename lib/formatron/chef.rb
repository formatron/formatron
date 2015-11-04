require 'formatron/cloud_formation_stack'
require_relative 'chef/keys'

class Formatron
  # manage the instance provisioning with Chef
  module Chef
    # rubocop:disable Metrics/MethodLength
    def self.provision(aws:, configuration:, target:)
      name = configuration.name target
      hosted_zone_name = configuration.hosted_zone_name target
      username = configuration.chef_username target
      organization = configuration.chef_organization target
      ssl_verify = configuration.chef_ssl_verify target
      sub_domain = configuration.chef_sub_domain target
      chef_server_url = _chef_server_url(
        sub_domain: sub_domain,
        hosted_zone_name: hosted_zone_name,
        organization: organization
      )
      CloudFormationStack.stack_ready!(
        aws: aws,
        name: configuration.name(target),
        target: target
      )
      keys = Keys.new(
        aws: aws,
        bucket: configuration.bucket(target),
        name: name,
        target: target
      )
      _knife = Knife.new(
        keys: keys,
        chef_server_url: chef_server_url,
        username: username,
        organization: organization,
        ssl_verify: ssl_verify
      )
    end
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

    private_class_method(
      :_chef_server_url
    )
  end
end
