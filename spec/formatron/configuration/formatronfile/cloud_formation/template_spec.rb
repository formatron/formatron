require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation/template'

class Formatron
  class Configuration
    # namespacing for tests
    module CloudFormation
      describe Template do
        description = 'description'

        describe '#create' do
          it 'should return an empty template' do
            expect(Template.create(description)).to eql(
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
            )
          end
        end
      end
    end
  end
end
