require 'spec_helper'
require 'formatron/formatronfile'

describe Formatron::Formatronfile do
  include FakeFS::SpecHelpers

  before do
    Dir.mkdir('test')
    File.write(
      File.join('test', 'Formatronfile'),
      <<-EOH.gsub(/^\s{8}/, '')
        name 'test_name'
        s3_bucket 'test_s3_bucket'
        prefix 'test_prefix'
        kms_key 'test_kms_key'
        depends 'hello'
        depends 'banana'
        cloudformation do
          'cloudformation'
        end
        opscode do
          'opscode'
        end
      EOH
    )
    @formatronfile = Formatron::Formatronfile.new(
      File.join('test', 'Formatronfile')
    )
  end

  describe '#name' do
    it 'should set the name property' do
      expect(@formatronfile.name).to eql('test_name')
    end
  end

  describe '#s3_bucket' do
    it 'should set the s3_bucket property' do
      expect(@formatronfile.s3_bucket).to eql('test_s3_bucket')
    end
  end

  describe '#prefix' do
    it 'should set the prefix property' do
      expect(@formatronfile.prefix).to eql('test_prefix')
    end
  end

  describe '#kms_key' do
    it 'should set the kms_key property' do
      expect(@formatronfile.kms_key).to eql('test_kms_key')
    end
  end

  describe '#depends' do
    it 'should add to the depends array' do
      expect(@formatronfile.depends).to eql(%w(hello banana))
    end
  end

  describe '#cloudformation' do
    it 'should set the cloudformation property' do
      expect(@formatronfile.cloudformation.call).to eql('cloudformation')
    end
  end

  describe '#opscode' do
    it 'should set the opscode property' do
      expect(@formatronfile.opscode.call).to eql('opscode')
    end
  end
end
