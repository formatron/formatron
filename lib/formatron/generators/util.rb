require 'securerandom'

class Formatron
  module Generators
    # Utility methods
    module Util
      def self.guid
        Random.rand(36**8).to_s(36).upcase
      end

      def self.databag_secret
        SecureRandom.random_number(36**40).to_s(36).upcase
      end
    end
  end
end
