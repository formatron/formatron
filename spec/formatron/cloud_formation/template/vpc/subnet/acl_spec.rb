require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/acl'

class Formatron
  module CloudFormation
    class Template
      class VPC
        # rubocop:disable Metrics/ClassLength
        class Subnet
          describe ACL do
            describe '#merge' do
              before :each do
                dsl_acl = instance_double(
                  'Formatron::DSL::Formatron::VPC::Subnet::ACL'
                )
                vpc_guid = 'vpc_guid'
                vpc_cidr = 'vpc_cidr'
                ec2 = class_double(
                  'Formatron::CloudFormation::Resources::EC2'
                ).as_stubbed_const
                @network_acl = 'network_acl'
                vpc_id = "vpc#{vpc_guid}"
                allow(ec2).to receive(:network_acl).with(
                  vpc: vpc_id
                ) { @network_acl }
                subnet_guid = 'subnet_guid'
                subnet_id = "subnet#{subnet_guid}"
                @network_acl_id = "networkAcl#{subnet_guid}"
                @subnet_network_acl_association_id =
                  "subnetNetworkAclAssociation#{subnet_guid}"
                @subnet_network_acl_association =
                  'subnet_network_acl_association'
                allow(ec2).to receive(:subnet_network_acl_association).with(
                  subnet: subnet_id,
                  network_acl: @network_acl_id
                ) { @subnet_network_acl_association }
                @network_acl_entry_vpc_inbound_id =
                  "vpcInboundNetworkAclEntry#{subnet_guid}"
                @network_acl_entry_vpc_inbound =
                  'network_acl_entry_vpc_inbound'
                allow(ec2).to receive(:network_acl_entry).with(
                  network_acl: @network_acl_id,
                  cidr: vpc_cidr,
                  egress: false,
                  protocol: -1,
                  action: 'allow',
                  icmp_code: -1,
                  icmp_type: -1,
                  number: 100
                ) { @network_acl_entry_vpc_inbound }
                @network_acl_entry_external_inbound_tcp_id =
                  "externalInboundTcpNetworkAclEntry#{subnet_guid}"
                @network_acl_entry_external_inbound_tcp =
                  'network_acl_entry_external_inbound_tcp'
                allow(ec2).to receive(:network_acl_entry).with(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: false,
                  protocol: 6,
                  action: 'allow',
                  start_port: 1024,
                  end_port: 65_535,
                  number: 200
                ) { @network_acl_entry_external_inbound_tcp }
                @network_acl_entry_external_inbound_udp_id =
                  "externalInboundUdpNetworkAclEntry#{subnet_guid}"
                @network_acl_entry_external_inbound_udp =
                  'network_acl_entry_external_inbound_udp'
                allow(ec2).to receive(:network_acl_entry).with(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: false,
                  protocol: 17,
                  action: 'allow',
                  start_port: 1024,
                  end_port: 65_535,
                  number: 300
                ) { @network_acl_entry_external_inbound_udp }
                @network_acl_entry_outbound_id =
                  "outboundNetworkAclEntry#{subnet_guid}"
                @network_acl_entry_outbound = 'network_acl_entry_outbound'
                allow(ec2).to receive(:network_acl_entry).with(
                  network_acl: @network_acl_id,
                  cidr: '0.0.0.0/0',
                  egress: true,
                  protocol: -1,
                  action: 'allow',
                  icmp_code: -1,
                  icmp_type: -1,
                  number: 400
                ) { @network_acl_entry_outbound }
                @resources = {}
                source_cidrs = []
                @network_acl_entry_external_inbounds = {}
                (0..9).each do |index|
                  source_cidr = "source_cidr#{index}"
                  source_cidrs.push source_cidr
                  network_acl_entry_external_inbound =
                    "network_acl_entry_external_inbound#{index}"
                  network_acl_entry_external_inbound_id =
                    "externalInboundNetworkAclEntry#{index}#{subnet_guid}"
                  @network_acl_entry_external_inbounds[
                    network_acl_entry_external_inbound_id
                  ] = network_acl_entry_external_inbound
                  allow(ec2).to receive(:network_acl_entry).with(
                    network_acl: @network_acl_id,
                    cidr: source_cidr,
                    egress: false,
                    protocol: -1,
                    action: 'allow',
                    icmp_code: -1,
                    icmp_type: -1,
                    number: 500 + index
                  ) { network_acl_entry_external_inbound }
                end
                allow(dsl_acl).to receive(
                  :source_cidr
                ) { source_cidrs }
                template_acl = ACL.new(
                  acl: dsl_acl,
                  subnet_guid: subnet_guid,
                  vpc_guid: vpc_guid,
                  vpc_cidr: vpc_cidr
                )
                template_acl.merge resources: @resources
              end

              it 'should add a network ACL' do
                expect(@resources).to include(
                  @network_acl_id => @network_acl
                )
              end

              it 'should add a subnet network ACL association' do
                expect(@resources).to include(
                  @subnet_network_acl_association_id =>
                    @subnet_network_acl_association
                )
              end

              it 'should add default rules' do
                expect(@resources).to include(
                  @network_acl_entry_vpc_inbound_id =>
                    @network_acl_entry_vpc_inbound,
                  @network_acl_entry_external_inbound_tcp_id =>
                    @network_acl_entry_external_inbound_tcp,
                  @network_acl_entry_external_inbound_udp_id =>
                    @network_acl_entry_external_inbound_udp,
                  @network_acl_entry_outbound_id =>
                    @network_acl_entry_outbound
                )
              end

              it 'should add source CIDR rules' do
                expect(@resources).to include(
                  @network_acl_entry_external_inbounds
                )
              end
            end
          end
        end
        # rubocop:enable Metrics/ClassLength
      end
    end
  end
end
