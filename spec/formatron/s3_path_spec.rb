require 'spec_helper'
require 'formatron/aws'
require 'formatron/configuration'
require 'formatron/s3_path'

# namespacing for tests
class Formatron
  describe S3Path do
    region = 'region'
    target = 'target'
    name = 'name'
    bucket = 'bucket'
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
        expect(
          S3Path.path(
            configuration: @configuration,
            target: target,
            sub_path: sub_path
          )
        ).to eql(
          File.join(target, name, sub_path)
        )
      end
    end

    describe '::url' do
      it 'should create a standard url including the ' \
          'configuration name and target' do
        expect(@configuration).to receive(:name).twice.with(
          target
        ) { name }
        expect(@configuration).to receive(:bucket).once.with(
          target
        ) { bucket }
        path = S3Path.path(
          configuration: @configuration,
          target: target,
          sub_path: sub_path
        )
        expect(
          S3Path.url(
            region: region,
            configuration: @configuration,
            target: target,
            sub_path: sub_path
          )
        ).to eql(
          "https://s3-#{region}.amazonaws.com/#{bucket}/#{path}"
        )
      end
    end
  end
end
