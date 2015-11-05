require 'spec_helper'
require 'formatron/cloud_formation' \
        '/template/resources/route53'

class Formatron
  module CloudFormation
    module Template
      # namespacing for tests
      # rubocop:disable Metrics/ModuleLength
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

          describe '::add_record_sets' do
            before :each do
              @template = {}
              @public_hosted_zone_id = 'public_hosted_zone_id'
              @private_hosted_zone_id = 'private_hosted_zone_id'
              @hosted_zone_name = 'hosted_zone_name'
              @prefix = 'prefix'
              @sub_domain = 'sub_domain'
              allow(Route53).to receive(
                :record_set
              # rubocop:disable Metrics/LineLength
              ) do |hosted_zone_id:, sub_domain:, hosted_zone_name:, instance:, attribute:|
                # rubocop:enable Metrics/LineLength
                {
                  hosted_zone_id: hosted_zone_id,
                  sub_domain: sub_domain,
                  hosted_zone_name: hosted_zone_name,
                  instance: instance,
                  attribute: attribute
                }
              end
            end

            context 'with a public subnet' do
              before :each do
                subnet = instance_double(
                  'Formatron::Configuration::Formatronfile' \
                  '::Bootstrap::VPC::Subnet'
                )
                allow(subnet).to receive(:public?) { true }
                Route53.add_record_sets(
                  template: @template,
                  public_hosted_zone_id: @public_hosted_zone_id,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  hosted_zone_name: @hosted_zone_name,
                  prefix: @prefix,
                  sub_domain: @sub_domain,
                  subnet: subnet
                )
              end

              it 'should add public and private recordsets' do
                expect(@template).to eql(
                  Resources: {
                    "#{@prefix}PrivateRecordSet" => {
                      hosted_zone_id: @private_hosted_zone_id,
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name,
                      instance: "#{@prefix}Instance",
                      attribute: 'PrivateIp'
                    },
                    "#{@prefix}PublicRecordSet" => {
                      hosted_zone_id: @public_hosted_zone_id,
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name,
                      instance: "#{@prefix}Instance",
                      attribute: 'PublicIp'
                    }
                  }
                )
              end
            end

            context 'with a private subnet' do
              before :each do
                subnet = instance_double(
                  'Formatron::Configuration::Formatronfile' \
                  '::Bootstrap::VPC::Subnet'
                )
                allow(subnet).to receive(:public?) { false }
                Route53.add_record_sets(
                  template: @template,
                  public_hosted_zone_id: @public_hosted_zone_id,
                  private_hosted_zone_id: @private_hosted_zone_id,
                  hosted_zone_name: @hosted_zone_name,
                  prefix: @prefix,
                  sub_domain: @sub_domain,
                  subnet: subnet
                )
              end

              it 'should add a private recordset' do
                expect(@template).to eql(
                  Resources: {
                    "#{@prefix}PrivateRecordSet" => {
                      hosted_zone_id: @private_hosted_zone_id,
                      sub_domain: @sub_domain,
                      hosted_zone_name: @hosted_zone_name,
                      instance: "#{@prefix}Instance",
                      attribute: 'PrivateIp'
                    }
                  }
                )
              end
            end
          end
        end
      end
      # rubocop:enable Metrics/ModuleLength
    end
  end
end
