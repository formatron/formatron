class Formatron
  module Support
    # Configuration and outputs for a deployed Formatron stack
    class FormatronStack
      attr_accessor :configuration, :outputs

      def initialize
        @configuration = nil
        @outputs = nil
      end
    end
  end
end
