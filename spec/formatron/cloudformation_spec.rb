require 'spec_helper'
require 'formatron/cloudformation'

describe Formatron::Cloudformation do
  include FakeFS::SpecHelpers

  before(:each) do
    @s3_client = instance_double('Aws::S3::Client')
    @cloudformation_client = instance_double('Aws::CloudFormation::Client')
    @aws = instance_double('Formatron::Aws')
    expect(@aws).to receive(:s3_client).with(
      no_args
    ).once { @s3_client }
    expect(aws).to receive(:cloudformation_client).with(
      no_args
    ).once { @cloudformation_client }
    @cloudformation_dir = File.join('test', 'cloudformation')
    FileUtils.mkdir_p(cloudformation_dir)
    File.write(
      File.join(
        cloudformation_dir,
        'main.json.erb'
      ),
      '<%= config[:param1] %>'
    )
    File.write(
      File.join(
        cloudformation_dir,
        'sub.json.erb'
      ),
      '<%= config[:param2] %>'
    )
    @config = instance_double('Formatron::Config')
    expect(@config).to receive(:hash).with(no_args).once do
      {
        param1: 'param1',
        param2: 'param2'
      }
    end
  end

  context 'with cloudformation configuration' do
    before(:each) do
      @cloudformation = Formatron::Cloudformation.new(
        @aws,
        @cloudformation_dir
      )
    end

    describe '#deploy' do
      skip 'should upload the cloudformation templates ' \
         'and create the cloudformation stack' do
        @cloudformation.deploy @config
      end
    end

    describe '#stack?' do
      skip 'it should return true' do
        expect(@cloudformation.stack?).to eql(true)
      end
    end

    context 'when the cloudformation stack is ready' do
      describe '#ready?' do
        skip 'it should return true' do
          expect(@cloudformation.ready?).to eql(true)
        end
      end
    end

    context 'when the cloudformation stack is not ready' do
      describe '#ready?' do
        skip 'it should return false' do
          expect(@cloudformation.ready?).to eql(false)
        end
      end
    end
  end

  context 'without cloudformation configuration' do
    before(:each) do
      @cloudformation = Formatron::Cloudformation.new(
        @aws,
        File.join(@cloudformation_dir, 'no_config_here')
      )
    end

    describe '#stack?' do
      skip 'it should return false' do
        expect(@cloudformation.stack?).to eql(false)
      end
    end
  end
end
