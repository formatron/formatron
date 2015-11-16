require 'formatron/util/vpc'

class Formatron
  # namespacing for tests
  module Util
    describe VPC do
      describe '::instances' do
        it 'should merge the lists of instances for the given symbol' do
          shared_subnet_names = (0..2).collect { |i| "shared#{i}" }
          local_subnet_names = (0..2).collect do |i|
            "local#{i}"
          end.concat shared_subnet_names
          external_subnet_names = (0..2).collect do |i|
            "external#{i}"
          end.concat shared_subnet_names
          local_subnets =
            local_subnet_names.each_with_object({}) do |k, o|
              o[k] = instance_double 'Formatron::DSL::Formatron::VPC::Subnet'
              nat_keys = (0..2).collect { |i| "nat#{i}#{k}" }
              nats = nat_keys.each_with_object({}) do |nk, no|
                no[nk] = "local#{nk}"
              end
              allow(o[k]).to receive(:nat) { nats }
            end
          external_subnets =
            external_subnet_names.each_with_object({}) do |k, o|
              o[k] = instance_double 'Formatron::DSL::Formatron::VPC::Subnet'
              nat_keys = (0..2).collect { |i| "nat#{i}#{k}" }
              nats = nat_keys.each_with_object({}) do |nk, no|
                no[nk] = "external#{nk}"
              end
              allow(o[k]).to receive(:nat) { nats }
            end
          local = instance_double 'Formatron::DSL::Formatron::VPC'
          allow(local).to receive(:subnet) { local_subnets }
          external = instance_double 'Formatron::DSL::Formatron::VPC'
          allow(external).to receive(:subnet) { external_subnets }
          expected_nats = (0..2).each_with_object({}) do |i, o|
            (0..2).each do |ni|
              o["nat#{ni}shared#{i}"] = "localnat#{ni}shared#{i}"
            end
            (0..2).each do |ni|
              o["nat#{ni}local#{i}"] = "localnat#{ni}local#{i}"
            end
            (0..2).each do |ni|
              o["nat#{ni}external#{i}"] = "externalnat#{ni}external#{i}"
            end
          end
          expect(VPC.instances(:nat, external, local)).to eql expected_nats
        end
      end
    end
  end
end
