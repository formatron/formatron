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
    sub_key = 'sub_key'

    describe '::key' do
      it 'should create a standard key including the ' \
          'configuration name and target' do
        expect(
          S3Path.key(
            name: name,
            target: target,
            sub_key: sub_key
          )
        ).to eql(
          File.join(target, name, sub_key)
        )
      end
    end

    describe '::url' do
      it 'should create a standard url including the ' \
          'configuration name and target' do
        key = S3Path.key(
          name: name,
          target: target,
          sub_key: sub_key
        )
        expect(
          S3Path.url(
            region: region,
            bucket: bucket,
            name: name,
            target: target,
            sub_key: sub_key
          )
        ).to eql(
          "https://s3-#{region}.amazonaws.com/#{bucket}/#{key}"
        )
      end
    end
  end
end
