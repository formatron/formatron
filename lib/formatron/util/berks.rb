require_relative 'kernel_helper'
require 'English'

class Formatron
  module Util
    # Wrapper for the berks cli
    class Berks
      class Error < RuntimeError
      end

      class VendorError < Error
      end

      class UploadEnvironmentError < Error
      end

      def self.vendor(cookbook, dir, with_lockfile = false)
        berksfile = File.join(cookbook, 'Berksfile')
        cookbooks_dir = with_lockfile ? File.join(dir, 'cookbooks') : dir
        FileUtils.mkdir_p cookbooks_dir
        KernelHelper.shell("berks vendor -b #{berksfile} #{cookbooks_dir}")
        fail(
          VendorError,
          "failed to vendor cookbooks for Berksfile #{berksfile} to #{dir}"
        ) unless KernelHelper.success?
        return unless with_lockfile
        lockfile = File.join(cookbook, 'Berksfile.lock')
        FileUtils.cp lockfile, dir
      end

      def initialize(server_url, user, key, organization, ssl_verify)
        @key_file = Tempfile.new('berks_key')
        @key_file.write(key)
        @key_file.close
        @config_file = Tempfile.new('berks')
        @config_file.write <<-EOH.gsub(/^\s{8}/, '')
          {
            "chef": {
              "chef_server_url": "#{server_url}/organizations/#{organization}",
              "node_name": "#{user}",
              "client_key": "#{@key_file.path}"
            },
            "ssl": {
              "verify": #{ssl_verify ? 'true' : 'false'}
            }
          }
        EOH
        @config_file.close
      end

      def unlink
        @config_file.unlink
        @key_file.unlink
      end

      def upload_environment(cookbook, environment)
        # rubocop:disable Metrics/LineLength
        KernelHelper.shell "berks install -b #{File.join(cookbook, 'Berksfile')}"
        fail UploadEnvironmentError, "failed to download cookbooks for opscode environment: #{environment}" unless KernelHelper.success?
        KernelHelper.shell "berks upload -c #{@config_file.path} -b #{File.join(cookbook, 'Berksfile')}"
        fail UploadEnvironmentError, "failed to upload cookbooks for opscode environment: #{environment}" unless KernelHelper.success?
        KernelHelper.shell "berks apply #{environment} -c #{@config_file.path} -b #{File.join(cookbook, 'Berksfile.lock')}"
        fail UploadEnvironmentError, "failed to apply cookbooks to opscode environment: #{environment}" unless KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
