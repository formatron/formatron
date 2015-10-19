module Formatron
  module Support
    # Stub S3 get_object response class
    class S3GetObjectResponse
      attr_reader :body

      # Stub S3 get_object response.body class
      class Body
        attr_reader :read

        def initialize(body)
          @read = body
        end
      end

      def initialize(body)
        @body = Body.new body
      end
    end
  end
end
