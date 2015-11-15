require 'formatron/dsl/formatron/vpc/subnet/acl'

class Formatron
  class DSL
    class Formatron
      class VPC
        # namespacing for tests
        class Subnet
          describe ACL do
            extend DSLTest

            dsl_before_block do
              @external = instance_double(
                'Formatron::External::VPC::Subnet::ACL'
              )
              { external: @external }
            end

            dsl_array :source_cidr

            describe '#external' do
              it 'should return the corresponding external ACL' do
                expect(@dsl_instance.external).to eql @external
              end
            end
          end
        end
      end
    end
  end
end
