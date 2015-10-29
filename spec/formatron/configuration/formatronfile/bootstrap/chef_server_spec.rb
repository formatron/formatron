require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap/chef_server'

class Formatron
  class Configuration
    class Formatronfile
      # namespacing for tests
      class Bootstrap
        describe ChefServer do
          before(:each) do
            @chef_server = ChefServer.new
          end

          %i(
            subnet
            sub_domain
            instance_cookbook
            organization
            username
            email
            first_name
            last_name
            password
            ssl_key
            ssl_cert
            ssl_verify
          ).each do |symbol|
            describe "\##{symbol}" do
              it "should set the #{symbol} field" do
                expect(@chef_server.send(symbol)).to be_nil
                @chef_server.send symbol, symbol.to_s
                expect(@chef_server.send(symbol)).to eql symbol.to_s
              end
            end
          end
        end
      end
    end
  end
end
