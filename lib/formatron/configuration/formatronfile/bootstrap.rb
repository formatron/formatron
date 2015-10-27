class Formatron
  class Configuration
    class Formatronfile
      # The bootstrap configuration
      class Bootstrap
        attr_reader(
          :protect
        )

        def initialize(protect)
          @protect = protect
        end
      end
    end
  end
end
