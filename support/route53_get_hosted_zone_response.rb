class Formatron
  module Support
    # Stub Route53 get_hosted_zone response class
    class Route53GetHostedZoneResponse
      attr_reader :hosted_zone

      # Stub Route53 get_hosted_zone response.hosted_zone class
      class HostedZone
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end

      def initialize(name)
        @hosted_zone = HostedZone.new name
      end
    end
  end
end
