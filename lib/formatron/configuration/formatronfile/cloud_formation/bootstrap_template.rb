require_relative 'template'
require 'json'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation bootstrap template JSON
        module BootstrapTemplate
          # rubocop:disable Metrics/MethodLength
          # rubocop:disable Metrics/ParameterLists
          def self.json(
            hosted_zone_id:,
            hosted_zone_name:,
            bootstrap:,
            bucket:,
            config_key:,
            user_pem_key:,
            organization_pem_key:,
            ssl_cert_key:,
            ssl_key_key:
          )
            template = _create_template
            _add_region_map template
            _add_private_hosted_zone template, hosted_zone_name
            _add_vpc template, bootstrap
            %i(
              add_nat
              add_bastion
            ).each do |symbol|
              Template.send(
                symbol,
                template: template,
                hosted_zone_id: hosted_zone_id,
                hosted_zone_name: hosted_zone_name,
                bootstrap: bootstrap,
                bucket: bucket,
                config_key: config_key
              )
            end
            Template.add_chef_server(
              template: template,
              hosted_zone_id: hosted_zone_id,
              hosted_zone_name: hosted_zone_name,
              bootstrap: bootstrap,
              bucket: bucket,
              config_key: config_key,
              user_pem_key: user_pem_key,
              organization_pem_key: organization_pem_key,
              ssl_cert_key: ssl_cert_key,
              ssl_key_key: ssl_key_key
            )
            "#{JSON.pretty_generate template}\n"
          end
          # rubocop:enable Metrics/ParameterLists
          # rubocop:enable Metrics/MethodLength

          def self._create_template
            Template.create(
              'formatron-bootstrap'
            )
          end

          def self._add_region_map(template)
            Template.add_region_map(
              template: template
            )
          end

          def self._add_private_hosted_zone(template, hosted_zone_name)
            Template.add_private_hosted_zone(
              template: template,
              hosted_zone_name: hosted_zone_name
            )
          end

          def self._add_vpc(template, bootstrap)
            Template.add_vpc(
              template: template,
              vpc: bootstrap.vpc
            )
          end

          private_class_method(
            :_create_template,
            :_add_region_map,
            :_add_private_hosted_zone,
            :_add_vpc
          )
        end
      end
    end
  end
end
