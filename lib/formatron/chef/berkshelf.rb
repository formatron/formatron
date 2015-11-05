require 'formatron/util/kernel_helper'
require 'English'

class Formatron
  module Chef
    # Wrapper for the berkshelf cli
    class Berkshelf
      class Error < RuntimeError
      end

      class VendorError < Error
      end

      class UploadEnvironmentError < Error
      end

      CONFIG_FILE = <<-EOH.gsub(/^\s{8}/, '')
        {
          "chef": {
            "chef_server_url": "%{server_url}/organizations/%{organization}",
            "node_name": "%{user}",
            "client_key": "%{key_file}"
          },
          "ssl": {
            "verify": %{ssl_verify}
          }
        }
      EOH

      def self.vendor(cookbook, dir, with_lockfile = false)
        _fetch_cookbooks cookbook, dir, with_lockfile
        return unless with_lockfile
        _add_lockfile cookbook, dir
      end

      def initialize(server_url, user, key, organization, ssl_verify)
        _create_key_file key
        _create_config_file server_url, user, organization, ssl_verify
      end

      def unlink
        @config_file.unlink
        @key_file.unlink
      end

      def upload_environment(cookbook, environment)
        # rubocop:disable Metrics/LineLength
        Util::KernelHelper.shell "berks install -b #{File.join(cookbook, 'Berksfile')}"
        fail UploadEnvironmentError, "failed to download cookbooks for opscode environment: #{environment}" unless Util::KernelHelper.success?
        Util::KernelHelper.shell "berks upload -c #{@config_file.path} -b #{File.join(cookbook, 'Berksfile')}"
        fail UploadEnvironmentError, "failed to upload cookbooks for opscode environment: #{environment}" unless Util::KernelHelper.success?
        Util::KernelHelper.shell "berks apply #{environment} -c #{@config_file.path} -b #{File.join(cookbook, 'Berksfile.lock')}"
        fail UploadEnvironmentError, "failed to apply cookbooks to opscode environment: #{environment}" unless Util::KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end

      def _create_key_file(key)
        @key_file = Tempfile.new('berks_key')
        @key_file.write(key)
        @key_file.close
      end

      def _create_config_file(server_url, user, organization, ssl_verify)
        @config_file = Tempfile.new('berks')
        @config_file.write CONFIG_FILE % {
          server_url: server_url,
          user: user,
          organization: organization,
          key_file: @key_file.path,
          ssl_verify: ssl_verify ? 'true' : 'false'
        }
        @config_file.close
      end

      def self._fetch_cookbooks(cookbook, dir, with_lockfile)
        berksfile = File.join(cookbook, 'Berksfile')
        cookbooks_dir = with_lockfile ? File.join(dir, 'cookbooks') : dir
        FileUtils.mkdir_p cookbooks_dir
        Util::KernelHelper.shell(
          "berks vendor -b #{berksfile} #{cookbooks_dir}"
        )
        fail(
          VendorError,
          "failed to vendor cookbooks for Berksfile #{berksfile} to #{dir}"
        ) unless Util::KernelHelper.success?
      end

      def self._add_lockfile(cookbook, dir)
        lockfile = File.join(cookbook, 'Berksfile.lock')
        FileUtils.cp lockfile, dir
      end

      private(
        :_create_key_file,
        :_create_config_file
      )

      private_class_method(
        :_fetch_cookbooks,
        :_add_lockfile
      )
    end
  end
end
