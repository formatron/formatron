require 'deep_merge'
require 'formatron/s3/configuration'
require 'formatron/dsl/formatron'

class Formatron
  class External
    # merges the given configuration into a formatron object
    # rubocop:disable Metrics/ModuleLength
    module DSL
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def self.merge(formatron:, configuration:)
        new_global = configuration['global']
        formatron.global do |global|
          global.protect(
            new_global['protect']
          ) unless new_global['protect'].nil?
          global.kms_key(
            new_global['kms_key']
          ) unless new_global['kms_key'].nil?
          global.databag_secret(
            new_global['databag_secret']
          ) unless new_global['databag_secret'].nil?
          global.hosted_zone_id(
            new_global['hosted_zone_id']
          ) unless new_global['hosted_zone_id'].nil?
          new_ec2 = new_global['ec2']
          global.ec2 do |ec2|
            ec2.key_pair(
              new_ec2['key_pair']
            ) unless new_ec2['key_pair'].nil?
            ec2.private_key(
              new_ec2['private_key']
            ) unless new_ec2['private_key'].nil?
          end unless new_ec2.nil?
        end unless new_global.nil?
        new_vpcs = configuration['vpcs']
        new_vpcs.each do |vpc_key, new_vpc|
          formatron.vpc vpc_key do |vpc|
            vpc.guid new_vpc['guid']
            vpc.cidr new_vpc['cidr']
            new_subnets = new_vpc['subnets']
            new_subnets.each do |subnet_key, new_subnet|
              vpc.subnet subnet_key do |subnet|
                subnet.guid new_subnet['guid']
                subnet.availability_zone new_subnet['availability_zone']
                subnet.gateway new_subnet['gateway']
                new_nats = new_subnet['nats']
                new_nats.each do |nat_key, new_nat|
                  subnet.nat nat_key do |nat|
                    nat.guid new_nat['guid']
                  end
                end
                new_bastions = new_subnet['bastions']
                new_bastions.each do |bastion_key, new_bastion|
                  subnet.bastion bastion_key do |bastion|
                    bastion.guid new_bastion['guid']
                  end
                end
                new_chef_servers = new_subnet['chef_servers']
                new_chef_servers.each do |chef_server_key, new_chef_server|
                  subnet.chef_server chef_server_key do |chef_server|
                    chef_server.guid new_chef_server['guid']
                    chef_server.username new_chef_server['username']
                    chef_server.ssl_verify new_chef_server['ssl_verify']
                    chef_server.sub_domain new_chef_server['sub_domain']
                    chef_server.organization do |organization|
                      organization.short_name(
                        new_chef_server['organization_short_name']
                      )
                    end
                    chef_server.stack new_chef_server['stack']
                  end
                end
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def self.export(formatron:)
        name = formatron.name
        global = formatron.global
        vpcs = formatron.vpc
        configuration = {
          'vpcs' => {}
        }
        unless global.nil?
          configuration_global = configuration['global'] = {}
          configuration_global['protect'] =
            global.protect unless global.protect.nil?
          configuration_global['kms_key'] =
            global.kms_key unless global.kms_key.nil?
          configuration_global['databag_secret'] =
            global.databag_secret unless global.databag_secret.nil?
          configuration_global['hosted_zone_id'] =
            global.hosted_zone_id unless global.hosted_zone_id.nil?
          ec2 = global.ec2
          unless ec2.nil?
            configuration_ec2 = configuration_global['ec2'] = {}
            configuration_ec2['key_pair'] =
              ec2.key_pair unless ec2.key_pair.nil?
            configuration_ec2['private_key'] =
              ec2.private_key unless ec2.private_key.nil?
          end
        end
        vpcs.each do |vpc_key, vpc|
          vpc_configuration = configuration['vpcs'][vpc_key] = {
            'subnets' => {},
            'guid' => vpc.guid,
            'cidr' => vpc.cidr
          }
          subnets = vpc.subnet
          subnets.each do |subnet_key, subnet|
            subnet_configuration =
              vpc_configuration['subnets'][subnet_key] = {
                'nats' => {},
                'bastions' => {},
                'chef_servers' => {},
                'guid' => subnet.guid,
                'availability_zone' => subnet.availability_zone,
                'gateway' => subnet.gateway
              }
            nats = subnet.nat
            bastions = subnet.bastion
            chef_servers = subnet.chef_server
            nats.each do |nat_key, nat|
              subnet_configuration['nats'][nat_key] = {
                'guid' => nat.guid
              }
            end
            bastions.each do |bastion_key, bastion|
              subnet_configuration['bastions'][bastion_key] = {
                'guid' => bastion.guid
              }
            end
            chef_servers.each do |chef_server_key, chef_server|
              subnet_configuration['chef_servers'][chef_server_key] = {
                'guid' => chef_server.guid,
                'username' => chef_server.username,
                'ssl_verify' => chef_server.ssl_verify,
                'sub_domain' => chef_server.sub_domain,
                'organization_short_name' =>
                  chef_server.organization.short_name,
                'stack' => chef_server.stack || name
              }
            end
          end
        end
        configuration
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
