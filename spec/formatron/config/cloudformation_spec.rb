require 'spec_helper'
require 'formatron/config/cloudformation'

describe Formatron::Config::Cloudformation do
  it 'should evaluate the block in the context ' \
     'of the the supplied configuration' do
    cloudformation = Formatron::Config::Cloudformation.new(
      param1: 'param1',
      param2: 'param2'
    ) do
      parameter 'parameter1', @config[:param1]
      parameter 'parameter2', @config[:param2]
    end
    expect(cloudformation.parameters).to eql(
      'parameter1' => 'param1',
      'parameter2' => 'param2'
    )
  end
end
