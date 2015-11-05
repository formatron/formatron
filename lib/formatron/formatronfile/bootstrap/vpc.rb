require_relative 'vpc/subnet'

class Formatron
  class Formatronfile
    class Bootstrap
      # VPC configuration
      class VPC
        attr_reader :subnets

        def initialize
          @subnets = {}
        end

        def cidr(value = nil)
          @cidr = value unless value.nil?
          @cidr
        end

        def subnet(name)
          subnet = Subnet.new
          @subnets[name] = subnet
          yield subnet
          subnet
        end
      end
    end
  end
end
