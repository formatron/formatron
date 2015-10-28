require 'spec_helper'
require 'formatron/configuration/formatronfile'
require 'formatron/configuration/formatronfile/cloud_formation'

class Formatron
  class Configuration
    # namespacing for tests
    class Formatronfile
      describe CloudFormation do
        describe '::template' do
          before(:each) do
            @formatronfile = instance_double 'Formatronfile'
          end

          skip 'should return the CloudFormation template for ' \
             'a Formatron configuration' do
            expect(
              CloudFormation.template(
                @formatronfile
              )
            ).to eql <<-EOH.gsub(/^ {8}/, '')
            EOH
          end
        end
      end
    end
  end
end
