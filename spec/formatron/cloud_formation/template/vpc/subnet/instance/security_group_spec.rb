require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/security_group'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # rubocop:disable Metrics/ClassLength
          class Instance
            describe SecurityGroup do
              describe '#merge' do
                before :each do
                  guid = 'guid'
                  vpc_guid = 'vpc_guid'
                  @cidr = 'cidr'
                  @dsl_security_group = instance_double(
                    'Formatron::DSL::Formatron::VPC::Subnet' \
                    '::Instance::SecurityGroup'
                  )

                  open_tcp_ports = []
                  open_udp_ports = []
                  @egress_rules = [{
                    cidr: '0.0.0.0/0',
                    protocol: 'tcp',
                    from_port: '0',
                    to_port: '65535'
                  }, {
                    cidr: '0.0.0.0/0',
                    protocol: 'udp',
                    from_port: '0',
                    to_port: '65535'
                  }, {
                    cidr: '0.0.0.0/0',
                    protocol: 'icmp',
                    from_port: '-1',
                    to_port: '-1'
                  }]
                  @ingress_tcp_rules = []
                  @ingress_udp_rules = []
                  (0..9).each do |index|
                    open_tcp_port = "tcp#{index}"
                    @ingress_tcp_rules.push(
                      cidr: '0.0.0.0/0',
                      protocol: 'tcp',
                      from_port: open_tcp_port,
                      to_port: open_tcp_port
                    )
                    open_tcp_ports[index] = open_tcp_port
                    open_udp_port = "udp#{index}"
                    @ingress_udp_rules.push(
                      cidr: '0.0.0.0/0',
                      protocol: 'udp',
                      from_port: open_udp_port,
                      to_port: open_udp_port
                    )
                    open_udp_ports[index] = open_udp_port
                  end
                  allow(@dsl_security_group).to receive(
                    :open_tcp_port
                  ) { open_tcp_ports }
                  allow(@dsl_security_group).to receive(
                    :open_udp_port
                  ) { open_udp_ports }

                  @vpc_id = "vpc#{vpc_guid}"
                  @security_group_id = "securityGroup#{guid}"
                  @security_group = 'security_group'
                  @ec2 = class_double(
                    'Formatron::CloudFormation::Resources::EC2'
                  ).as_stubbed_const

                  @resources = {}
                end

                context 'when the os is linux' do
                  before :each do
                    ingress_rules = [{
                      cidr: @cidr,
                      protocol: 'tcp',
                      from_port: '0',
                      to_port: '65535'
                    }, {
                      cidr: @cidr,
                      protocol: 'udp',
                      from_port: '0',
                      to_port: '65535'
                    }, {
                      cidr: @cidr,
                      protocol: 'icmp',
                      from_port: '-1',
                      to_port: '-1'
                    }]
                    allow(@ec2).to receive(:security_group).with(
                      group_description: 'Formatron instance security group',
                      vpc: @vpc_id,
                      egress: @egress_rules,
                      ingress: ingress_rules.concat(
                        @ingress_tcp_rules
                      ).concat(
                        @ingress_udp_rules
                      )
                    ) { @security_group }
                    template_security_group = SecurityGroup.new(
                      os: 'os',
                      security_group: @dsl_security_group,
                      instance_guid: 'guid',
                      vpc_guid: 'vpc_guid',
                      vpc_cidr: 'cidr'
                    )
                    template_security_group.merge resources: @resources
                  end

                  it 'should add a security group' do
                    expect(@resources).to include(
                      @security_group_id => @security_group
                    )
                  end
                end

                context 'when the os is windows' do
                  before :each do
                    ingress_rules = [{
                      cidr: @cidr,
                      protocol: 'tcp',
                      from_port: '0',
                      to_port: '65535'
                    }, {
                      cidr: @cidr,
                      protocol: 'udp',
                      from_port: '0',
                      to_port: '65535'
                    }, {
                      cidr: @cidr,
                      protocol: 'icmp',
                      from_port: '-1',
                      to_port: '-1'
                    }, {
                      cidr: '0.0.0.0/0',
                      protocol: 'tcp',
                      from_port: '3389',
                      to_port: '3389'
                    }, {
                      cidr: '0.0.0.0/0',
                      protocol: 'tcp',
                      from_port: '5985',
                      to_port: '5985'
                    }]
                    allow(@ec2).to receive(:security_group).with(
                      group_description: 'Formatron instance security group',
                      vpc: @vpc_id,
                      egress: @egress_rules,
                      ingress: ingress_rules.concat(
                        @ingress_tcp_rules
                      ).concat(
                        @ingress_udp_rules
                      )
                    ) { @security_group }
                    template_security_group = SecurityGroup.new(
                      os: 'windows',
                      security_group: @dsl_security_group,
                      instance_guid: 'guid',
                      vpc_guid: 'vpc_guid',
                      vpc_cidr: 'cidr'
                    )
                    template_security_group.merge resources: @resources
                  end

                  it 'should add a security group' do
                    expect(@resources).to include(
                      @security_group_id => @security_group
                    )
                  end
                end
              end
            end
          end
          # rubocop:enable Metrics/ClassLength
        end
      end
    end
  end
end
