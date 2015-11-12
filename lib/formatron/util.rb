class Formatron
  # Utility methods
  module Util
    def self.guid
      Random.rand(36**8).to_s(36).upcase
    end
  end
end
