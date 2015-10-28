class Formatron
  class Configuration
    class Formatronfile
      # The bootstrap configuration
      class Bootstrap
        attr_reader(
          :protect,
          :kms_key
        )

        def initialize(protect, kms_key)
          @protect = protect
          @kms_key = kms_key
        end
      end
    end
  end
end
