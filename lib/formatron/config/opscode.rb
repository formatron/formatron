class Formatron
  class Config
    class Opscode
      attr_reader :config

      def initialize(config, &block)
        @config = config
        @server_url = nil
        @user = nil
        @organization = nil
        @ssl_verify = true
        @is_chef_server = false
        instance_eval(&block) if block_given?
      end

      def server_url(value = nil)
        @server_url = value unless value.nil?
        @server_url
      end

      def user(value = nil)
        @user = value unless value.nil?
        @user
      end

      def organization(value = nil)
        @organization = value unless value.nil?
        @organization
      end

      def ssl_verify(value = nil)
        @ssl_verify = value unless value.nil?
        @ssl_verify
      end

      def deploys_chef_server(value = nil)
        @deploys_chef_server = value unless value.nil?
        @deploys_chef_server
      end
    end
  end
end
