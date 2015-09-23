require_relative 'kernel_helper'
require 'English'

class Formatron
  module Util
    # Wrapper for the berks cli
    class Knife
      class Error < RuntimeError
      end

      class CreateEnvironmentError < Error
      end

      def initialize(server_url, user, key, organization, ssl_verify)
        _create_key_file key
        _create_knife_file server_url, user, organization, ssl_verify
      end

      def unlink
        @knife_file.unlink
        @key_file.unlink
      end

      def create_environment(environment)
        # rubocop:disable Metrics/LineLength
        KernelHelper.shell "knife environment show #{environment} -c #{@knife_file.path}"
        KernelHelper.shell "knife environment create #{environment} -c #{@knife_file.path} -d '#{environment} environment created by formatron'" unless KernelHelper.success?
        fail CreateEnvironmentError, "failed to create opscode environment: #{environment}" unless KernelHelper.success?
        # rubocop:enable Metrics/LineLength
      end

      def _create_key_file(key)
        @key_file = Tempfile.new('knife_key')
        @key_file.write(key)
        @key_file.close
      end

      def _create_knife_file(server_url, user, organization, ssl_verify)
        @knife_file = Tempfile.new('knife')
        @knife_file.write <<-EOH.gsub(/^\s{8}/, '')
          chef_server_url '#{server_url}/organizations/#{organization}'
          node_name '#{user}'
          client_key '#{@key_file.path}'
          ssl_verify_mode #{ssl_verify ? ':verify_peer' : ':verify_none'}
        EOH
        @knife_file.close
      end

      private(
        :_create_key_file,
        :_create_knife_file
      )
    end
  end
end
