require 'formatron/dsl/formatron'
require 'formatron/external/dsl'

class Formatron
  # namespacing for tests
  class External
    describe DSL do
      describe '#merge/#export' do
        it 'should convert to and back from a DSL Formatron object' do
          aws = instance_double 'Formatron::AWS'
          allow(aws).to receive(:hosted_zone_name).with(
            'hosted_zone_id'
          ) { 'hosted_zone_name' }
          formatron = Formatron::DSL::Formatron.new external: nil, aws: aws
          configuration = {
            'global' => {
              'protect' => true,
              'kms_key' => 'kms_key',
              'hosted_zone_id' => 'hosted_zone_id',
              'hosted_zone_name' => 'hosted_zone_name',
              'ec2' => {
                'key_pair' => 'key_pair',
                'private_key' => 'private_key'
              }
            },
            'vpcs' => {
              'vpc1' => {
                'guid' => 'vpc1_guid',
                'cidr' => 'vpc1_cidr',
                'subnets' => {
                  'subnet1' => {
                    'guid' => 'subnet1_guid',
                    'availability_zone' => 'subnet1_availability_zone',
                    'gateway' => 'subnet1_gateway',
                    'nats' => {
                      'nat1' => {
                        'guid' => 'nat1_guid'
                      },
                      'nat2' => {
                        'guid' => 'nat2_guid'
                      }
                    },
                    'bastions' => {
                      'bastion1' => {
                        'guid' => 'bastion1_guid',
                        'sub_domain' => 'bastion1_sub_domain'
                      },
                      'bastion2' => {
                        'guid' => 'bastion2_guid',
                        'sub_domain' => 'bastion2_sub_domain'
                      }
                    },
                    'chef_servers' => {
                      'chef_server1' => {
                        'guid' => 'chef_server1_guid',
                        'username' => 'chef_server1_username',
                        'ssl_verify' => true,
                        'sub_domain' => 'chef_server1_sub_domain',
                        'organization_short_name' =>
                          'chef_server1_short_name',
                        'stack' => 'chef_server1_stack'
                      },
                      'chef_server2' => {
                        'guid' => 'chef_server2_guid',
                        'username' => 'chef_server2_username',
                        'ssl_verify' => false,
                        'sub_domain' => 'chef_server2_sub_domain',
                        'organization_short_name' =>
                          'chef_server2_short_name',
                        'stack' => 'chef_server2_stack'
                      }
                    }
                  },
                  'subnet2' => {
                    'guid' => 'subnet2_guid',
                    'availability_zone' => 'subnet2_availability_zone',
                    'gateway' => 'subnet2_gateway',
                    'nats' => {},
                    'bastions' => {},
                    'chef_servers' => {}
                  }
                }
              },
              'vpc2' => {
                'guid' => 'vpc2_guid',
                'cidr' => 'vpc2_cidr',
                'subnets' => {}
              }
            }
          }
          DSL.merge formatron: formatron, configuration: configuration
          new_configuration = DSL.export formatron: formatron
          expect(new_configuration).to eql configuration
        end
      end
    end
  end
end
