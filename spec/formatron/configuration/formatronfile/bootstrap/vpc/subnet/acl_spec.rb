require 'formatron/configuration/formatronfile/bootstrap/vpc/subnet/acl'

class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        class VPC
          # namespacing for tests
          class Subnet
            describe ACL do
              before :each do
                @acl = ACL.new
              end

              describe '#source_ip' do
                it 'should append to the list of allowed source IPs' do
                  expect(@acl.source_ips).to be_nil
                  @acl.source_ip '1'
                  expect(@acl.source_ips).to eql %w(1)
                  @acl.source_ip '2'
                  expect(@acl.source_ips).to eql %w(1 2)
                end
              end
            end
          end
        end
      end
    end
  end
end
