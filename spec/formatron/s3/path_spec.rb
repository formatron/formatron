require 'spec_helper'
require 'formatron/s3/path'

class Formatron
  # namespacing for tests
  module S3
    describe Path do
      region = 'region'
      target = 'target'
      name = 'name'
      bucket = 'bucket'
      sub_key = 'sub_key'

      describe '::key' do
        it 'should create a standard key including the ' \
            'configuration name and target' do
          expect(
            Path.key(
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
          key = Path.key(
            name: name,
            target: target,
            sub_key: sub_key
          )
          expect(
            Path.url(
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
end
