class Formatron
  class Formatronfile
    # dependency configuration
    class Dependency
      attr_reader(
        :name
      )

      def initialize(aws:, bucket:, target:, name:)
        @aws = aws
        @bucket = bucket
        @target = target
        @name = name
      end
    end
  end
end
