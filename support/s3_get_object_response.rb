class Formatron
  module Support
    # Stub S3 get_object response class
    class S3GetObjectResponse
      attr_reader :body

      # Stub S3 get_object response.body class
      class Body
        attr_reader :read

        def initialize(content)
          @read = content
        end
      end

      def initialize(content)
        @body = Body.new content
      end
    end
  end
end
