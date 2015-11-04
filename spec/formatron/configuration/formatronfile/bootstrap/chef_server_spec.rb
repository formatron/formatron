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

          it { is_expected.to be_an(Instance) }

          %i(
            version
            cookbooks_bucket
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

          describe '#organization' do
            before :each do
              @organization = double
              allow(ChefServer::Organization).to receive(:new) { @organization }
              allow(@organization).to receive :test
            end

            it 'should set the organization configuration and ' \
               'yield to the organization block' do
              @chef_server.organization(&:test)
              expect(@chef_server.organization).to eql @organization
              expect(@organization).to have_received(:test).once.with no_args
            end
          end
        end
      end
    end
  end
end
