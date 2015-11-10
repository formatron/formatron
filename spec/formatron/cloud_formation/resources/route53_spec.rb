require 'spec_helper'
require 'formatron/cloud_formation' \
        '/resources/route53'

class Formatron
  module CloudFormation
    # namespacing for tests
    module Resources
      describe Route53 do
        describe '::hosted_zone' do
          it 'should return a HostedZone resource' do
            name = 'name'
            vpc = 'vpc'
            expect(
              Route53.hosted_zone(
                name: name,
                vpc: vpc
              )
            ).to eql(
              Type: 'AWS::Route53::HostedZone',
              Properties: {
                HostedZoneConfig: {
                  Comment: {
                    'Fn::Join' => [
                      '', [
                        'Private Hosted Zone for CloudFormation Stack: ', {
                          Ref: 'AWS::StackName'
                        }
                      ]
                    ]
                  }
                },
                Name: name,
                VPCs: [{
                  VPCId: { Ref: vpc },
                  VPCRegion: { Ref: 'AWS::Region' }
                }]
              }
            )
          end
        end

        describe '::record_set' do
          it 'should return a RecordSet resource' do
            hosted_zone_id = 'hosted_zone_id'
            sub_domain = 'sub_domain'
            hosted_zone_name = 'hosted_zone_name'
            instance = 'instance'
            attribute = 'attribute'
            expect(
              Route53.record_set(
                hosted_zone_id: hosted_zone_id,
                sub_domain: sub_domain,
                hosted_zone_name: hosted_zone_name,
                instance: instance,
                attribute: attribute
              )
            ).to eql(
              Type: 'AWS::Route53::RecordSet',
              Properties: {
                HostedZoneId: hosted_zone_id,
                Name: "#{sub_domain}.#{hosted_zone_name}",
                ResourceRecords: [
                  { 'Fn::GetAtt' => [instance, attribute] }
                ],
                TTL: '900',
                Type: 'A'
              }
            )
          end
        end
      end
    end
  end
end
