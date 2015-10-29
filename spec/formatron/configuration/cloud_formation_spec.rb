require 'spec_helper'
require 'formatron/configuration/formatronfile'
require 'formatron/configuration/cloud_formation'

class Formatron
  # namespacing for tests
  class Configuration
    describe CloudFormation do
      describe '::template' do
        before(:each) do
          @formatronfile = instance_double(
            'Formatron::Configuration::Formatronfile'
          )
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
