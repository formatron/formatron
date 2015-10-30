require_relative 'template'
require 'json'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        # Generates CloudFormation bootstrap template JSON
        module BootstrapTemplate
          def self.json(region:, bucket:, target:, name:, bootstrap:)
            puts region
            puts bucket
            template = Template.create "bootstrap-#{name}-#{target}"
            Template.add_vpc(
              template: template,
              vpc: bootstrap.vpc
            )
            "#{JSON.pretty_generate template}\n"
          end
        end
      end
    end
  end
end
