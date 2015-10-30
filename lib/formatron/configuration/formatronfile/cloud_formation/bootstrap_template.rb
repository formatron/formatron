require_relative 'template'
require 'json'

class Formatron
  class Configuration
    module CloudFormation
      # Generates CloudFormation bootstrap template JSON
      module BootstrapTemplate
        def self.json(region:, bucket:, target:, name:, bootstrap:)
          puts region
          puts bucket
          puts bootstrap
          template = Template.create "bootstrap-#{name}-#{target}"
          "#{JSON.pretty_generate template}\n"
        end
      end
    end
  end
end
