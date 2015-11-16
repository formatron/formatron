class Formatron
  module Util
    # utility methods for VPCs
    module VPC
      def self.instances(symbol, *vpcs)
        subnets = vpcs.each_with_object([]) do |v, a|
          a.concat v.subnet.values
        end
        subnets.each_with_object({}) do |s, o|
          o.merge!(s.send(symbol))
        end
      end
    end
  end
end
