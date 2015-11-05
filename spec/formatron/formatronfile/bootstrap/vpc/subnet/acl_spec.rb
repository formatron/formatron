require 'formatron/formatronfile/bootstrap/vpc/subnet/acl'

class Formatron
  class Formatronfile
    class Bootstrap
      class VPC
        # namespacing for tests
        class Subnet
          describe ACL do
            before :each do
              @acl = ACL.new
            end

            describe '#source_cidr' do
              it 'should append to the list of allowed source CIDRs' do
                expect(@acl.source_cidrs).to be_nil
                @acl.source_cidr '1'
                expect(@acl.source_cidrs).to eql %w(1)
                @acl.source_cidr '2'
                expect(@acl.source_cidrs).to eql %w(1 2)
              end
            end
          end
        end
      end
    end
  end
end
