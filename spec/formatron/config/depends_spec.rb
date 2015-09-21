require 'spec_helper'

require 'aws-sdk'
require 'formatron/config/depends'

include Formatron::Support

describe Formatron::Config::Depends do
  before(:each) do
    @s3_client = instance_double('Aws::S3::Client')
    @cloudformation_client = instance_double('Aws::CloudFormation::Client')
    @depends = Formatron::Config::Depends.new(
      @s3_client, @cloudformation_client
    )
  end

  context 'when the dependency has cloudformation outputs' do
    before(:each) do
      expect(@s3_client).to receive(:get_object).with(
        bucket: 'bucket',
        key: 'target/stack/config.json'
      ).once do
        S3GetObjectResponse.new <<-EOH.gsub(/\s{10}/, '')
          {
            "test1": "depends1",
            "test2": "depends2",
            "stack": {
              "test3": "depends3",
              "formatronOutputs": {}
            }
          }
        EOH
      end
      expect(@cloudformation_client).to receive(:describe_stacks).with(
        stack_name: 'prefix-stack-target'
      ).once do
        CloudformationDescribeStacksResponse.new [
          name: 'test4',
          value: 'depends4'
        ]
      end
      @config = @depends.load(
        'bucket',
        'prefix',
        'stack',
        'target',
        'test1' => 'config1'
      )
    end

    describe '#load' do
      it 'should merge the config and outputs ' \
         'for the specified stack from S3' do
        expect(@config).to eql(
          'test1' => 'config1',
          'test2' => 'depends2',
          'stack' => {
            'test3' => 'depends3',
            'formatronOutputs' => {
              'test4' => 'depends4'
            }
          }
        )
      end
    end
  end

  context 'when the dependency does not have cloudformation outputs' do
    before(:each) do
      expect(@s3_client).to receive(:get_object).with(
        bucket: 'bucket',
        key: 'target/stack/config.json'
      ).once do
        S3GetObjectResponse.new <<-EOH.gsub(/\s{10}/, '')
          {
            "test1": "depends1",
            "test2": "depends2",
            "stack": {
              "test3": "depends3"
            }
          }
        EOH
      end
      @config = @depends.load(
        'bucket',
        'prefix',
        'stack',
        'target',
        'test1' => 'config1'
      )
    end

    describe '#load' do
      it 'should merge the config and outputs ' \
         'for the specified stack from S3' do
        expect(@config).to eql(
          'test1' => 'config1',
          'test2' => 'depends2',
          'stack' => {
            'test3' => 'depends3'
          }
        )
      end
    end
  end

  context 'when the dependency cloudformation stack is not ready' do
    before(:each) do
      expect(@s3_client).to receive(:get_object).with(
        bucket: 'bucket',
        key: 'target/stack/config.json'
      ).once do
        S3GetObjectResponse.new <<-EOH.gsub(/\s{10}/, '')
          {
            "test1": "depends1",
            "test2": "depends2",
            "stack": {
              "test3": "depends3",
              "formatronOutputs": {}
            }
          }
        EOH
      end
      expect(@cloudformation_client).to receive(:describe_stacks).with(
        stack_name: 'prefix-stack-target'
      ).once do
        CloudformationDescribeStacksResponse.new [
          name: 'test4',
          value: 'depends4'
        ], 'CREATE_FAILED'
      end
    end

    describe '#load' do
      it 'should fail' do
        expect do
          @config = @depends.load(
            'bucket',
            'prefix',
            'stack',
            'target',
            'test1' => 'config1'
          )
        end.to raise_error('Stack dependency not ready: prefix-stack-target')
      end
    end
  end
end
