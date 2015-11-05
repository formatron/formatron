require 'spec_helper'
require 'formatron/config/reader'

class Formatron
  # namespacing for tests
  # rubocop:disable Metrics/ModuleLength
  module Config
    describe Reader do
      include FakeFS::SpecHelpers

      before(:each) do
        Dir.mkdir('test')
      end

      context 'with just a default json file' do
        before(:each) do
          File.write(
            'test/default.json', <<-EOH.gsub(/\s{14}/, '')
              {
                "test": "value"
              }
            EOH
          )
          @config = Reader.read(
            'test',
            'default.json'
          )
        end

        it 'should read the json into a hash' do
          expect(@config).to eql(
            'test' => 'value'
          )
        end
      end

      context 'with files but no default json file' do
        before(:each) do
          File.write(
            'test/test-key', <<-EOH.gsub(/\s{14}/, '')
              another value
            EOH
          )
          @config = Reader.read(
            'test',
            'default.json'
          )
        end

        it 'should add the file content as a key to the hash' do
          expect(@config).to eql(
            'test-key' => "another value\n"
          )
        end
      end

      context 'with files and a default json file' do
        before(:each) do
          File.write(
            'test/test-key', <<-EOH.gsub(/\s{14}/, '')
              another value
            EOH
          )
          File.write(
            'test/default.json', <<-EOH.gsub(/\s{14}/, '')
              {
                "test": "value",
                "test-key": "overriden value"
              }
            EOH
          )
          @config = Reader.read(
            'test',
            'default.json'
          )
        end

        it 'should merge the keys using the files to override the json' do
          expect(@config).to eql(
            'test' => 'value',
            'test-key' => "another value\n"
          )
        end
      end

      context 'with sub directories' do
        before(:each) do
          File.write(
            'test/test-key', <<-EOH.gsub(/\s{14}/, '')
              another value
            EOH
          )
          File.write(
            'test/default.json', <<-EOH.gsub(/\s{14}/, '')
              {
                "test": "value",
                "test-key": "overriden value",
                "hello": "something",
                "banana": {
                  "fruit": true
                }
              }
            EOH
          )
          Dir.mkdir('test/hello')
          File.write(
            'test/hello/default.json', <<-EOH.gsub(/\s{14}/, '')
              {
                "more-test": "hello",
                "and-again": "override me"
              }
            EOH
          )
          File.write(
            'test/hello/and-again', <<-EOH.gsub(/\s{14}/, '')
              new value
            EOH
          )
          Dir.mkdir('test/banana')
          File.write(
            'test/banana/default.json', <<-EOH.gsub(/\s{14}/, '')
              {
                "color": "yellow"
              }
            EOH
          )
          @config = Reader.read(
            'test',
            'default.json'
          )
        end

        it 'should recurse and merge everything' do
          expect(@config).to eql(
            'test' => 'value',
            'test-key' => "another value\n",
            'hello' => {
              'more-test' => 'hello',
              'and-again' => "new value\n"
            },
            'banana' => {
              'fruit' => true,
              'color' => 'yellow'
            }
          )
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
