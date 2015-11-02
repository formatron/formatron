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
              def self.hosted_zone(name:, region:, vpc:)
                {
                  Type: 'AWS::Route53::HostedZone',
                  Properties: {
                    HostedZoneConfig: {
                      Comment: Template.join(
                        [
                          'Private Hosted Zone for CloudFormation Stack: ',
                          Template.ref('AWS::StackName')
                        ]
                      )
                    },
                    Name: name,
                    VPCs: [{
                      VPCId: Template.ref(vpc),
                      VPCRegion: region
                    }]
                  }
                }
              end
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
