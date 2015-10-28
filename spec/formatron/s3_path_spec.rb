require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_path'

describe Formatron::S3Path do
  target = 'target'
  name = 'name'
  sub_path = 'sub_path'

  before(:each) do
    @aws = instance_double 'Formatron::AWS'
    @configuration = instance_double 'Formatron::Configuration'
  end

  describe '::path' do
    it 'should create a standard path including the ' \
        'configuration name and target' do
      expect(@configuration).to receive(:name).once.with(
        target
      ) { name }
      expect(Formatron::S3Path.path(@configuration, target, sub_path)).to eql(
        File.join(target, name, sub_path)
      )
    end
  end
end
