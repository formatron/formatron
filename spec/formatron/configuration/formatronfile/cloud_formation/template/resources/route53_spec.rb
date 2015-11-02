require 'spec_helper'
require 'formatron/configuration/formatronfile/cloud_formation' \
        '/template/resources/route53'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
          # namespacing for tests
          module Resources
            describe Route53 do
              describe '::hosted_zone' do
                it 'should return a HostedZone resource' do
                  name = 'name'
                  region = 'region'
                  vpc = 'vpc'
                  expect(
                    Route53.hosted_zone(
                      name: name,
                      region: region,
                      vpc: vpc
                    )
                  ).to eql(
                    Type: 'AWS::Route53::HostedZone',
                    Properties: {
                      HostedZoneConfig: {
                        Comment: {
                          'Fn::Join'.to_sym => [
                            '', [
                              # rubocop:disable Metrics/LineLength
                              'Private Hosted Zone for CloudFormation Stack: ', {
                                # rubocop:enable Metrics/LineLength
                                'Ref': 'AWS::StackName'
                              }
                            ]
                          ]
                        }
                      },
                      Name: name,
                      VPCs: [{
                        VPCId: { 'Ref': vpc },
                        VPCRegion: region
                      }]
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
