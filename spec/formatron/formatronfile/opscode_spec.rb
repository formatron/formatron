require 'spec_helper'
require 'formatron/formatronfile/opscode'

describe Formatron::Formatronfile::Opscode do
  it 'should evaluate the block in the context ' \
     'of the the supplied configuration' do
    config = instance_double('Formatron::Config')
    expect(config).to receive(:hash).with(no_args).once do
      {
        param1: 'param1',
        param2: 'param2',
        param3: 'param3',
        param4: 'param4',
        param5: 'param5'
      }
    end
    opscode = Formatron::Formatronfile::Opscode.new(
      config,
      proc do
        server_url @config[:param1]
        user @config[:param2]
        organization @config[:param3]
        ssl_verify @config[:param4]
        server_stack @config[:param5]
      end
    )
    expect(opscode.server_url).to eql 'param1'
    expect(opscode.user).to eql 'param2'
    expect(opscode.organization).to eql 'param3'
    expect(opscode.ssl_verify).to eql 'param4'
    expect(opscode.server_stack).to eql 'param5'
  end
end
