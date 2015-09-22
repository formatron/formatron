require 'spec_helper'

require 'formatron/dependency'
require 'formatron/aws'

include Formatron::Support

describe Formatron::Dependency do
  before(:each) do
    @s3_client = instance_double('Aws::S3::Client')
    @cloudformation_client = instance_double('Aws::CloudFormation::Client')
    @aws = instance_double('Formatron::Aws')
    allow(@aws).to receive(:s3_client) { @s3_client }
    allow(@aws).to receive(:cloudformation_client) { @cloudformation_client }
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
            "stacks": {
              "stack": {
                "config": {
                  "test3": "depends3"
                },
                "outputs": {}
              }
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
      @dependency = Formatron::Dependency.new(
        @aws,
        s3_bucket: 'bucket',
        prefix: 'prefix',
        name: 'stack',
        target: 'target'
      )
    end

    it 'should collect the config and outputs ' \
       'for the specified stack from S3' do
      expect(@dependency.hash).to eql(
        'test1' => 'depends1',
        'test2' => 'depends2',
        'stacks' => {
          'stack' => {
            'config' => {
              'test3' => 'depends3'
            },
            'outputs' => {
              'test4' => 'depends4'
            }
          }
        }
      )
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
            "stacks": {
              "stack": {
                "config": {
                  "test3": "depends3"
                }
              }
            }
          }
        EOH
      end
      @dependency = Formatron::Dependency.new(
        @aws,
        s3_bucket: 'bucket',
        prefix: 'prefix',
        name: 'stack',
        target: 'target'
      )
    end

    it 'should collect the config ' \
       'for the specified stack from S3' do
      expect(@dependency.hash).to eql(
        'test1' => 'depends1',
        'test2' => 'depends2',
        'stacks' => {
          'stack' => {
            'config' => {
              'test3' => 'depends3'
            }
          }
        }
      )
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
            "stacks": {
              "stack": {
                "config": {
                  "test3": "depends3"
                },
                "outputs": {}
              }
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

    it 'should fail' do
      expect do
        Formatron::Dependency.new(
          @aws,
          s3_bucket: 'bucket',
          prefix: 'prefix',
          name: 'stack',
          target: 'target'
        )
      end.to raise_error('Stack dependency not ready: prefix-stack-target')
    end
  end
end
