require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      # dependency configuration
      class Dependency
        extend Util::DSL

        dsl_initialize_hash do |key, aws:, external:|
          puts key
          puts aws
          puts external
        end
      end
    end
  end
end
