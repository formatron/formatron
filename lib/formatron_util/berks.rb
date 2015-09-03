require 'English'

module FormatronUtil
  # Wrapper for the berks cli
  module Berks
    class Error < RuntimeError
    end

    class VendorError < Error
    end

    def self.vendor(berksfile, dir)
      `berks vendor -b #{berksfile} #{dir}`
      fail(
        VendorError,
        "failed to vendor cookbooks for Berksfile #{berksfile} to #{dir}"
      ) unless $CHILD_STATUS.success?
    end
  end
end
