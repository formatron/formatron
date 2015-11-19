require 'formatron/cloud_formation/resources/ec2'

class Formatron
  module CloudFormation
    class Template
      class VPC
        class Subnet
          class Instance
            # Adds block device mappings to an instance
            class BlockDevices
              def initialize(block_devices:)
                @block_devices = block_devices
              end

              # rubocop:disable Metrics/MethodLength
              def merge(properties:)
                return if @block_devices.length == 0
                block_device_mappings = @block_devices.map do |block_device|
                  Resources::EC2.block_device_mapping(
                    device: block_device.device,
                    size: block_device.size,
                    type: block_device.type,
                    iops: block_device.iops
                  )
                end
                properties[Resources::EC2::BLOCK_DEVICE_MAPPINGS] =
                  block_device_mappings
              end
              # rubocop:enable Metrics/MethodLength
            end
          end
        end
      end
    end
  end
end
