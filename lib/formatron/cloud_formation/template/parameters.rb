class Formatron
  module CloudFormation
    class Template
      # generates CloudFormation parameter declarations
      class Parameters
        def initialize(keys:)
          @keys = keys
        end

        def merge(parameters:)
          @keys.each do |key|
            parameters[key] = {
              Type: 'String'
            }
          end
        end
      end
    end
  end
end
