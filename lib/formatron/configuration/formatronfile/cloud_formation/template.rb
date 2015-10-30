class Formatron
  class Configuration
    module CloudFormation
      # Generates CLoudFormation template JSON
      class Template
        # rubocop:disable Metrics/MethodLength
        def self.create(description)
          {
            AWSTemplateFormatVersion: '2010-09-09',
            Description: "#{description}",
            Parameters: {
            },
            Mappings: {
            },
            Resources: {
            },
            Outputs: {
            }
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
