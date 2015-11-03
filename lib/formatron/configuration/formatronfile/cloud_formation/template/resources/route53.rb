require_relative '../../template'

class Formatron
  class Configuration
    class Formatronfile
      module CloudFormation
        module Template
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

              # rubocop:disable Metrics/MethodLength
              # rubocop:disable Metrics/ParameterLists
              def self.add_record_sets(
                template:,
                public_hosted_zone_id:,
                private_hosted_zone_id:,
                hosted_zone_name:,
                prefix:,
                sub_domain:,
                subnet:
              )
                resources = Template.resources template
                resources[
                  "#{prefix}#{Template::PRIVATE_RECORD_SET}"
                ] = record_set(
                  hosted_zone_id: private_hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name,
                  instance: "#{prefix}#{Template::INSTANCE}",
                  attribute: 'PrivateIp'
                )
                resources[
                  "#{prefix}#{Template::PUBLIC_RECORD_SET}"
                ] = record_set(
                  hosted_zone_id: public_hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name,
                  instance: "#{prefix}#{Template::INSTANCE}",
                  attribute: 'PublicIp'
                ) if subnet.public?
              end
              # rubocop:enable Metrics/ParameterLists
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
