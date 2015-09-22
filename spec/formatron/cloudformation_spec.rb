require 'spec_helper'
require 'formatron/cloudformation'

describe Formatron::Cloudformation do
  it 'should evaluate the block in the context ' \
     'of the the supplied configuration' do
    config = instance_double('Formatron::Config')
    expect(config).to receive(:hash).with(no_args).once do
      {
        param1: 'param1',
        param2: 'param2'
      }
    end
    cloudformation = Formatron::Cloudformation.new(
      config, proc do
        parameter 'parameter1', @config[:param1]
        parameter 'parameter2', @config[:param2]
      end
    )
    expect(cloudformation.parameters).to eql(
      'parameter1' => 'param1',
      'parameter2' => 'param2'
    )
  end
end
