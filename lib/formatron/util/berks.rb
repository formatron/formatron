require 'English'

class Formatron
  module Util
    # Wrapper for the berks cli
    module Berks
      class Error < RuntimeError
      end

      class VendorError < Error
      end

      def self.vendor(cookbook, dir, with_lockfile = false)
        berksfile = File.join(cookbook, 'Berksfile')
        cookbooks_dir = with_lockfile ? File.join(dir, 'cookbooks') : dir
        FileUtils.mkdir_p cookbooks_dir
        `berks vendor -b #{berksfile} #{cookbooks_dir}`
        fail(
          VendorError,
          "failed to vendor cookbooks for Berksfile #{berksfile} to #{dir}"
        ) unless $CHILD_STATUS.success?
        if with_lockfile
          lockfile = File.join(cookbook, 'Berksfile.lock')
          FileUtils.cp lockfile, dir
        end
      end
    end
  end
end
