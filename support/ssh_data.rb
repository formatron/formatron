class Formatron
  module Support
    # Stub S3 get_object response class
    class SSHData
      attr_reader :read_long

      def initialize(data)
        @read_long = data
      end
    end
  end
end
