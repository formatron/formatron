class Formatron
  class Config
    class Opscode
      attr_reader :config, :_server_url, :_user, :_user_key, :_organization, :_ssl_self_signed_cert, :_deploys_chef_server

      def initialize (config, &block)
        @config = config
        @_server_url = nil
        @_user = nil
        @_user_key = nil
        @_organization = nil
        @_ssl_self_signed_cert = false
        @_is_chef_server = false
        if block_given?
          instance_eval(&block)
        end
      end

      def server_url (value)
        @_server_url = value
      end

      def user (value)
        @_user = value
      end

      def user_key (value)
        @_user_key = value
      end

      def organization (value)
        @_organization = value
      end

      def ssl_self_signed_cert (value)
        @_ssl_self_signed_cert = value
      end

      def deploys_chef_server (value)
        @_deploys_chef_server = value
      end

    end
  end
end
