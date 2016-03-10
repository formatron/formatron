require 'formatron/cloud_formation'
require 'formatron/logger'
require_relative 'chef/keys'
require_relative 'chef/berkshelf'
require_relative 'chef/knife'
require_relative 'chef/ssh'
require_relative 'chef/winrm'

class Formatron
  # manage the instance provisioning with Chef
  # rubocop:disable Metrics/ClassLength
  class Chef
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/ParameterLists
    # rubocop:disable Metrics/AbcSize
    def initialize(
      directory:,
      aws:,
      bucket:,
      name:,
      target:,
      ec2_key:,
      administrator_name:,
      administrator_password:,
      username:,
      organization:,
      ssl_verify:,
      chef_sub_domain:,
      bastions:,
      hosted_zone_name:,
      server_stack:,
      guid:,
      configuration:,
      databag_secret:
    )
      @working_directory = File.join directory, guid
      @aws = aws
      @name = name
      @target = target
      @chef_sub_domain = chef_sub_domain
      @hosted_zone_name = hosted_zone_name
      @organization = organization
      @server_stack = server_stack
      @bastions = bastions
      chef_server_url = _chef_server_url
      @keys = Keys.new(
        directory: @working_directory,
        aws: @aws,
        bucket: bucket,
        name: server_stack,
        target: @target,
        guid: guid,
        ec2_key: ec2_key
      )
      @knife = Knife.new(
        directory: @working_directory,
        keys: @keys,
        administrator_name: administrator_name,
        administrator_password: administrator_password,
        chef_server_url: chef_server_url,
        username: username,
        organization: organization,
        ssl_verify: ssl_verify,
        databag_secret: databag_secret,
        configuration: configuration
      )
      @berkshelf = Berkshelf.new(
        directory: @working_directory,
        keys: @keys,
        chef_server_url: chef_server_url,
        username: username,
        ssl_verify: ssl_verify
      )
      @ssh = SSH.new(
        keys: @keys
      )
      @winrm = WinRM.new(
        administrator_name: administrator_name,
        administrator_password: administrator_password
      )
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/ParameterLists
    # rubocop:enable Metrics/MethodLength

    def init
      CloudFormation.stack_ready!(
        aws: @aws,
        name: @server_stack,
        target: @target
      )
      FileUtils.mkdir_p @working_directory
      @keys.init
      @knife.init
      @berkshelf.init
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def provision(
      os:,
      sub_domain:,
      guid:,
      cookbook:,
      bastion:
    )
      Formatron::LOG.info do
        "Provision #{guid} with Chef cookbook: #{cookbook}"
      end
      bastion ||= @bastions.keys[0]
      bastion_hostname = _hostname(
        sub_domain: @bastions[bastion]
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
      Formatron::LOG.info do
        "Deploying data bag item '#{guid}' to chef server: #{@chef_sub_domain}"
      end
      @knife.deploy_databag name: guid
      Formatron::LOG.info do
        "Lock cookbook versions for environment #{guid}"
      end
      @knife.create_environment environment: guid
      @berkshelf.upload environment: guid, cookbook: cookbook
      if @knife.node_exists? guid: guid
        _reprovision_node(
          os: os,
          bastion_hostname: bastion_hostname,
          guid: guid,
          cookbook_name: cookbook_name,
          hostname: hostname
        )
      else
        _bootstrap_node(
          os: os,
          bastion_hostname: bastion_hostname,
          guid: guid,
          cookbook_name: cookbook_name,
          hostname: hostname
        )
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def _reprovision_node(
      os:,
      bastion_hostname:,
      guid:,
      cookbook_name:,
      hostname:
    )
      if _bootstrapped?(
        os: os,
        bastion_hostname: bastion_hostname,
        hostname: hostname
      )
        Formatron::LOG.info do
          "Run chef-client on existing node #{guid}"
        end
        _run_chef_client(
          os: os,
          bastion_hostname: bastion_hostname,
          hostname: hostname
        )
      else
        Formatron::LOG.info do
          "node #{guid} exists but has not been bootstrapped, " \
          'likely recreated so deleting node and bootstrapping again'
        end
        Formatron::LOG.info do
          "Deleting node '#{guid}' from chef server: #{@chef_sub_domain}"
        end
        @knife.delete_node node: guid
        Formatron::LOG.info do
          "Deleting client '#{guid}' from chef server: #{@chef_sub_domain}"
        end
        @knife.delete_client client: guid
        _bootstrap_node(
          os: os,
          bastion_hostname: bastion_hostname,
          guid: guid,
          cookbook_name: cookbook_name,
          hostname: hostname
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def _bootstrapped?(os:, bastion_hostname:, hostname:)
      if os.eql? 'windows'
        @winrm.bootstrapped? hostname: hostname
      else
        @ssh.bootstrapped?(
          bastion_hostname: bastion_hostname,
          hostname: hostname
        )
      end
    end

    def _run_chef_client(os:, bastion_hostname:, hostname:)
      if os.eql? 'windows'
        @winrm.run_chef_client hostname: hostname
      else
        @ssh.run_chef_client(
          bastion_hostname: bastion_hostname,
          hostname: hostname
        )
      end
    end

    # rubocop:disable Metrics/MethodLength
    def _bootstrap_node(
      os:,
      bastion_hostname:,
      guid:,
      cookbook_name:,
      hostname:
    )
      Formatron::LOG.info do
        "Bootstrap node #{guid}"
      end
      @knife.bootstrap(
        os: os,
        bastion_hostname: bastion_hostname,
        guid: guid,
        cookbook: cookbook_name,
        hostname: hostname
      )
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def destroy(guid:)
      Formatron::LOG.info do
        "Delete Chef configuration for node: #{guid}"
      end
      Formatron::LOG.info do
        "Deleting data bag item '#{guid}' from chef server: #{@chef_sub_domain}"
      end
      @knife.delete_databag name: guid
      Formatron::LOG.info do
        "Deleting node '#{guid}' from chef server: #{@chef_sub_domain}"
      end
      @knife.delete_node node: guid
      Formatron::LOG.info do
        "Deleting client '#{guid}' from chef server: #{@chef_sub_domain}"
      end
      @knife.delete_client client: guid
      Formatron::LOG.info do
        "Deleting environment '#{guid}' from chef server: #{@chef_sub_domain}"
      end
      @knife.delete_environment environment: guid
    end
    # rubocop:enable Metrics/MethodLength

    def _chef_server_url
      "https://#{@chef_sub_domain}.#{@hosted_zone_name}" \
      "/organizations/#{@organization}"
    end

    def _hostname(sub_domain:)
      "#{sub_domain}.#{@hosted_zone_name}"
    end

    private(
      :_chef_server_url,
      :_hostname,
      :_bootstrap_node,
      :_reprovision_node,
      :_bootstrapped?,
      :_run_chef_client
    )
  end
  # rubocop:enable Metrics/ClassLength
end
