require 'formatron/util/dsl'

class Formatron
  class DSL
    class Formatron
      # dependency configuration
      class Dependency
        extend Util::DSL

        dsl_initialize_hash do |dsl_key:, aws:|
          puts dsl_key
          puts aws
        end
      end
    end
  end
end
