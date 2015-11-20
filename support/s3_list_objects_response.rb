class Formatron
  module Support
    # Stub S3 list_objects response class
    class S3ListObjectsResponse
      attr_reader :contents

      # Stub S3 get_object response.body class
      class Contents
        attr_reader :key

        def initialize(key)
          @key = key
        end
      end

      def initialize(keys)
        @contents = keys.map { |key| Contents.new(key) }
      end
    end
  end
end
