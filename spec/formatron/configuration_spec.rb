require 'spec_helper'

require 'formatron/configuration'

describe Formatron::Configuration do
  describe '::deploy' do
    context 'with a bootstrap configuration' do
      context 'when the CloudFormation stack has not yet been created' do
        skip 'should create the CloudFormation stack' do
        end
      end

      context 'when the CloudFormation stack has been created' do
        skip 'should update the CloudFormation stack' do
        end

        skip 'should upload the Chef Server cookbooks' do
        end
      end
    end
  end
end
