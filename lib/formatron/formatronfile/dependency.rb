require 'formatron/util/dsl'

class Formatron
  class Formatronfile
    # dependency configuration
    class Dependency
      extend Util::DSL

      dsl_initialize_hash
    end
  end
end
