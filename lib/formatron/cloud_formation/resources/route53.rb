require_relative '../template'

class Formatron
  module CloudFormation
    module Resources
      # Generates CloudFormation template Route53 resources
      module Route53
        # rubocop:disable Metrics/MethodLength
        def self.hosted_zone(name:, vpc:)
          {
            Type: 'AWS::Route53::HostedZone',
            Properties: {
              HostedZoneConfig: {
                Comment: Template.join(
                  'Private Hosted Zone for CloudFormation Stack: ',
                  Template.ref('AWS::StackName')
                )
              },
              Name: name,
              VPCs: [{
                VPCId: Template.ref(vpc),
                VPCRegion: Template.ref('AWS::Region')
              }]
            }
          }
        end
        # rubocop:enable Metrics/MethodLength

        # rubocop:disable Metrics/MethodLength
        def self.record_set(
          hosted_zone_id:,
          sub_domain:,
          hosted_zone_name:,
          instance:,
          attribute:
        )
          {
            Type: 'AWS::Route53::RecordSet',
            Properties: {
              HostedZoneId: hosted_zone_id,
              Name: "#{sub_domain}.#{hosted_zone_name}",
              ResourceRecords: [
                Template.get_attribute(instance, attribute)
              ],
              TTL: '900',
              Type: 'A'
            }
          }
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
