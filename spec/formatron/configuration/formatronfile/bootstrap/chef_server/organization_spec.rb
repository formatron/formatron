require 'spec_helper'
require 'formatron/configuration/formatronfile/bootstrap' \
        '/chef_server/organization'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # namespacing for tests
        class ChefServer
          describe Organization do
            before(:each) do
              @organization = Organization.new
            end

            %i(
              short_name
              full_name
            ).each do |symbol|
              describe "\##{symbol}" do
                it "should set the #{symbol} field" do
                  expect(@organization.send(symbol)).to be_nil
                  @organization.send symbol, symbol.to_s
                  expect(@organization.send(symbol)).to eql symbol.to_s
                end
              end
            end
          end
        end
      end
    end
  end
end
