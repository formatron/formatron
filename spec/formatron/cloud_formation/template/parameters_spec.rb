require 'spec_helper'
require 'formatron/cloud_formation/template/parameters'

class Formatron
  module CloudFormation
    # namespacing for tests
    class Template
      describe Parameters do
        before :each do
          keys = %w(param1 param2 param3)
          @parameters = Parameters.new keys: keys
        end

        describe '#merge' do
          before :each do
            @object = {}
            @parameters.merge parameters: @object
          end

          it 'should declare the CloudFormation parameters' do
            expect(@object).to eql(
              'param1' => {
                Type: 'String'
              },
              'param2' => {
                Type: 'String'
              },
              'param3' => {
                Type: 'String'
              }
            )
          end
        end
      end
    end
  end
end
