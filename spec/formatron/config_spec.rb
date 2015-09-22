require 'spec_helper'

require 'formatron/config'

describe Formatron::Config do
  before(:each) do
    @reader_class = class_double('Formatron::Config::Reader').as_stubbed_const
    @dependency1 = instance_double('Formatron::Dependency')
    @dependency2 = instance_double('Formatron::Dependency')
  end

  context 'when there is no cloudformation stack or dependencies' do
    it 'should merge config into the hash object' do
      expect(@reader_class).to receive(:read).with(
        File.join('config', '_default'),
        '_default.json'
      ).once do
        {
          'test1' => 'default1',
          'test2' => 'default2'
        }
      end
      expect(@reader_class).to receive(:read).with(
        File.join('config', 'target'),
        '_default.json'
      ).once do
        {
          'test2' => 'target2',
          'test3' => 'target3'
        }
      end
      config = Formatron::Config.new(
        {
          name: 'name',
          target: 'target',
          s3_bucket: 'bucket',
          prefix: 'prefix',
          kms_key: 'kms_key'
        },
        'config', [], false
      )
      expect(config.hash).to eq(
        'name' => 'name',
        'target' => 'target',
        's3Bucket' => 'bucket',
        'prefix' => 'prefix',
        'kmsKey' => 'kms_key',
        'stacks' => {
          'name' => {
            'config' => {
              'test1' => 'default1',
              'test2' => 'target2',
              'test3' => 'target3'
            },
            'outputs' => nil
          }
        }
      )
    end
  end

  context 'when there is a cloudformation stack' do
    it 'should merge config into the hash object' do
      expect(@reader_class).to receive(:read).with(
        File.join('config', '_default'),
        '_default.json'
      ).once { {} }
      expect(@reader_class).to receive(:read).with(
        File.join('config', 'target'),
        '_default.json'
      ).once { {} }
      config = Formatron::Config.new(
        {
          name: 'name',
          target: 'target',
          s3_bucket: 'bucket',
          prefix: 'prefix',
          kms_key: 'kms_key'
        },
        'config', [], true
      )
      expect(config.hash).to eq(
        'name' => 'name',
        'target' => 'target',
        's3Bucket' => 'bucket',
        'prefix' => 'prefix',
        'kmsKey' => 'kms_key',
        'stacks' => {
          'name' => {
            'config' => {},
            'outputs' => {}
          }
        }
      )
    end
  end

  context 'when there are dependencies' do
    it 'should merge config into the hash object' do
      expect(@reader_class).to receive(:read).with(
        File.join('config', '_default'),
        '_default.json'
      ).once { {} }
      expect(@reader_class).to receive(:read).with(
        File.join('config', 'target'),
        '_default.json'
      ).once { {} }
      expect(@dependency1).to receive(:hash).with(no_args).once do
        {
          'name' => 'dependency1',
          'target' => 'target',
          's3Bucket' => 'bucket',
          'prefix' => 'prefix',
          'kmsKey' => 'kms_key',
          'stacks' => {
            'dependency1' => {
              'config' => {
                'config1' => 'config1'
              },
              'outputs' => {
                'output1' => 'output1'
              }
            }
          }
        }
      end
      expect(@dependency2).to receive(:hash).with(no_args).once do
        {
          'name' => 'dependency2',
          'target' => 'target',
          's3Bucket' => 'bucket',
          'prefix' => 'prefix',
          'kmsKey' => 'kms_key',
          'stacks' => {
            'dependency2' => {
              'config' => {
                'config2' => 'config2'
              },
              'outputs' => {
                'output2' => 'output2'
              }
            }
          }
        }
      end
      config = Formatron::Config.new(
        {
          name: 'name',
          target: 'target',
          s3_bucket: 'bucket'
        },
        'config', [
          @dependency1,
          @dependency2
        ], true
      )
      expect(config.hash).to eq(
        'name' => 'name',
        'target' => 'target',
        's3Bucket' => 'bucket',
        'prefix' => 'prefix',
        'kmsKey' => 'kms_key',
        'stacks' => {
          'name' => {
            'config' => {},
            'outputs' => {}
          },
          'dependency1' => {
            'config' => {
              'config1' => 'config1'
            },
            'outputs' => {
              'output1' => 'output1'
            }
          },
          'dependency2' => {
            'config' => {
              'config2' => 'config2'
            },
            'outputs' => {
              'output2' => 'output2'
            }
          }
        }
      )
    end
  end
end
