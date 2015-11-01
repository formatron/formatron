require_relative 'template'
require 'json'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation bootstrap template JSON
        module BootstrapTemplate
          def self.json(bootstrap:, bucket:, config_key:)
            template = _create_template
            _add_vpc template, bootstrap
            _add_nat template, bootstrap, bucket, config_key
            "#{JSON.pretty_generate template}\n"
          end

          def self._create_template
            Template.create(
              'formatron-bootstrap'
            )
          end

          def self._add_vpc(template, bootstrap)
            Template.add_vpc(
              template: template,
              vpc: bootstrap.vpc
            )
          end

          def self._add_nat(template, bootstrap, bucket, config_key)
            Template.add_nat(
              template: template,
              bootstrap: bootstrap,
              bucket: bucket,
              config_key: config_key
            )
          end

          private_class_method(
            :_create_template,
            :_add_vpc,
            :_add_nat
          )
        end
      end
    end
  end
end
