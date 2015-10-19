module Formatron
  module Util
    # wrapper for shelling out calls so that we can still test
    module KernelHelper
      # :nocov:
      def self.shell(command)
        `#{command}`
      end
      def self.success?
        $CHILD_STATUS.success?
      end
      # :nocov:
    end
  end
end
