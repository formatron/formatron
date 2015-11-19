require 'spec_helper'
require 'formatron/cloud_formation/template/vpc/subnet/instance/setup'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          # namespacing for tests
          class Instance
            describe BlockDevices do
              describe '#merge' do
                before :each do
                  ec2 = class_double(
                    'Formatron::CloudFormation::Resources::EC2'
                  ).as_stubbed_const transfer_nested_constants: true
                  dsl_block_devices = []
                  @block_device_mappings = []
                  (0..9).each do |index|
                    block_device_mapping = @block_device_mappings[index] =
                      "block_device_mapping#{index}"
                    dsl_block_device = dsl_block_devices[index] =
                      instance_double(
                        'Formatron::DSL::Formatron::VPC::Subnet' \
                        '::Instance::BlockDevice'
                      )
                    device = "device#{index}"
                    allow(dsl_block_device).to receive(:device) { device }
                    size = "size#{index}"
                    allow(dsl_block_device).to receive(:size) { size }
                    type = "type#{index}"
                    allow(dsl_block_device).to receive(:type) { type }
                    iops = "iops#{index}"
                    allow(dsl_block_device).to receive(:iops) { iops }
                    allow(ec2).to receive(:block_device_mapping).with(
                      device: device,
                      size: size,
                      type: type,
                      iops: iops
                    ) { block_device_mapping }
                  end
                  @properties = {}
                  block_devices = BlockDevices.new(
                    block_devices: dsl_block_devices
                  )
                  block_devices.merge properties: @properties
                end

                it 'should add the block device mappings' do
                  expect(@properties).to eql(
                    BlockDeviceMappings: @block_device_mappings
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
