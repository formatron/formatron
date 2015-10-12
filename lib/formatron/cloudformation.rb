class Formatron
  # Cloudformation configuration
  class Cloudformation
    def initialize(aws, dir)
      @aws = aws
      @dir = dir
    end

    def stack?
    end

    def ready?
    end
  end
end
