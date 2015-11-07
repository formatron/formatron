require 'formatron/logger'
require 'open3'

class Formatron
  module Util
    # wrapper for shelling out calls so that we can still test
    module Shell
      def self.exec(command)
        Open3.popen2e command do |_stdin, stdout_err, wait_thr|
          # rubocop:disable Lint/AssignmentInCondition
          while line = stdout_err.gets
            # rubocop:enable Lint/AssignmentInCondition
            Formatron::LOG.info line.chomp
          end
          return wait_thr.value.success?
        end
      end
    end
  end
end
