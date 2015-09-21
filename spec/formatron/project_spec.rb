require 'spec_helper.rb'

require 'formatron/project'

describe Formatron::Project do
  include FakeFS::SpecHelpers

  describe Formatron::Project::Error do
    it { should be_kind_of(RuntimeError) }
  end

  context 'when the directory does not exist' do
    it 'should raise an error' do
      expect do
        Formatron::Project.new('invalid')
      end.to raise_error(
        Formatron::Project::Error,
        'invalid is not a directory'
      )
    end
  end

  before(:each) do
    Dir.mkdir('test')
  end

  context 'without a Formatronfile' do
    it 'should raise an error' do
      expect do
        Formatron::Project.new('test')
      end.to raise_error(
        Formatron::Project::Error,
        'Formatronfile not found'
      )
    end
  end

  context 'with a super simple Formatron project' do
    before(:each) do
      File.write(
        File.join('test', 'Formatronfile'),
        <<-EOH.gsub(/^\s{10}/, '')
          name 'test_name'
          s3_bucket 'test_bucket'
          prefix 'test_prefix'
          kms_key 'test_kms_key'
        EOH
      )
    end

    it 'should initialize the config object' do
      config = instance_double('Formatron::Config')
      config_class = class_double('Formatron::Config').as_stubbed_const
      expect(config_class).to receive(:new).with(
        'test_name', {
          s3_bucket: 'test_bucket',
          prefix: 'test_prefix',
          kms_key: 'test_kms_key'
        },
        File.join('test', 'config'),
        []
      ).once { config }
      expect(Formatron::Project.new('test').config).to equal(config)
    end
  end

  context 'when there are dependencies' do
    before(:each) do
      File.write(
        File.join('test', 'Formatronfile'),
        <<-EOH.gsub(/^\s{10}/, '')
          depends 'dependency1'
          depends 'dependency2'
        EOH
      )
    end

    it 'should intialize the dependency instances ' \
       'and pass them to the config' do
      dependency1 = instance_double('Formatron::Dependency')
      dependency2 = instance_double('Formatron::Dependency')
      dependency_class = class_double('Formatron::Dependency').as_stubbed_const
      expect(dependency_class).to receive(:new).with(
        'dependency1'
      ).once { dependency1 }
      expect(dependency_class).to receive(:new).with(
        'dependency2'
      ).once { dependency2 }
      config = instance_double('Formatron::Config')
      config_class = class_double('Formatron::Config').as_stubbed_const
      expect(config_class).to receive(:new).with(
        nil, {
          s3_bucket: nil,
          prefix: nil,
          kms_key: nil
        },
        File.join('test', 'config'), [
          dependency1,
          dependency2
        ]
      ).once { config }
      expect(Formatron::Project.new('test').config).to equal(config)
    end
  end
end
