require 'spec_helper'
require 'formatron/util/tar'

describe Formatron::Util::Tar do
  include FakeFS::SpecHelpers

  describe '::tar' do
    before(:each) do
      Dir.mkdir('/test')
      File.write('/test/file', 'file1')
      File.chmod 0600, '/test/file'
      Dir.mkdir('/test/dir')
      File.chmod 0750, '/test/dir'
      File.write('/test/dir/file', 'file2')
      File.chmod 0700, '/test/dir/file'
      allow(StringIO).to receive(:new)
      @tarfile = instance_double('StringIO')
      expect(StringIO).to receive(:new).with(
        ''
      ).once { @tarfile }
      @tar = instance_double('Gem::Package::TarWriter')
      expect(Gem::Package::TarWriter).to receive(:new).with(
        @tarfile
      ).once.and_yield(@tar)
    end

    it 'should write to the tarfile and then rewind it' do
      file1 = double
      file2 = double
      expect(@tar).to receive(:mkdir).with(
        'dir',
        0100750
      ).once
      expect(@tar).to receive(:add_file).with(
        'file',
        0100600
      ).once.and_yield(file1)
      expect(@tar).to receive(:add_file).with(
        'dir/file',
        0100700
      ).once.and_yield(file2)
      expect(file1).to receive(:write).with(
        'file1'
      ).once
      expect(file2).to receive(:write).with(
        'file2'
      ).once
      expect(@tarfile).to receive(:rewind).with(no_args)
      Formatron::Util::Tar.tar('/test')
    end
  end

  describe '::gzip' do
    before(:each) do
      @tarfile = instance_double('StringIO')
      expect(@tarfile).to receive(:string).with(
        no_args
      ).once { 'hello' }
      gz = instance_double('StringIO')
      expect(StringIO).to receive(:new).with(
        ''
      ).once { gz }
      z = instance_double('Zlib::GzipWriter')
      expect(Zlib::GzipWriter).to receive(:new).with(
        gz
      ).once { z }
      expect(z).to receive(:write).with(
        'hello'
      )
      expect(z).to receive(:close).with(no_args).once
      expect(gz).to receive(:string).with(no_args) { 'banana' }
      @gzip = instance_double('StringIO')
      expect(StringIO).to receive(:new).with(
        'banana'
      ).once { @gzip }
    end

    it 'should gzip the supplied StringIO instance ' \
       'to another StringIO instance' do
      expect(Formatron::Util::Tar.gzip(@tarfile)).to equal(@gzip)
    end
  end
end
