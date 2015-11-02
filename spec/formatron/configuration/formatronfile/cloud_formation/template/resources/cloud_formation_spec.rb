require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation' \
        '/template/resources/cloud_formation'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
          # namespacing for tests
          module Resources
            describe CloudFormation do
              describe '::wait_condition_handle' do
                it 'should return a WaitConditionHandle resource' do
                  expect(
                    CloudFormation.wait_condition_handle
                  ).to eql(
                    Type: 'AWS::CloudFormation::WaitConditionHandle'
                  )
                end
              end

              describe '::wait_condition' do
                it 'should return a WaitCondtion resource' do
                  instance = 'instance'
                  wait_condition_handle = 'wait_condition_handle'
                  expect(
                    CloudFormation.wait_condition(
                      instance: instance,
                      wait_condition_handle: wait_condition_handle
                    )
                  ).to eql(
                    Type: 'AWS::CloudFormation::WaitCondition',
                    DependsOn: instance,
                    Properties: {
                      Handle: { Ref: wait_condition_handle },
                      Timeout: '1200'
                    }
                  )
                end
              end
            end
          end
        end
      end
    end
  end
end
