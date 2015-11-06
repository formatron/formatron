class Formatron
  module Util
    # wrapper for shelling out calls so that we can still test
    module KernelHelper
      def self.shell(command)
        puts command
        output = `#{command}`
        puts output
        output
      end

      def self.success?
        $CHILD_STATUS.success?
      end
    end
  end
end
