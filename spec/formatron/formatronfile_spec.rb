require 'spec_helper'
require 'formatron/formatronfile'

# namespacing for tests
class Formatron
  describe Formatronfile do
    include FakeFS::SpecHelpers

    file = 'Formatronfile'
    target = 'target'
    config = {}

    before(:each) do
      aws = instance_double 'Formatron::AWS'

      File.write(
        file,
        <<-'EOH'.gsub(/^ {8}/, '')
          name 'name'
          bucket 'bucket'
          depends 'dependency1'
          depends 'dependency2'
          bootstrap do |bootstrap|
            bootstrap.test(
              target,
              config,
              dependencies
            )
          end
        EOH
      )

      dependency_class = class_double(
        'Formatron::Formatronfile::Dependency'
      ).as_stubbed_const
      @dependencies = {
        'dependency1' => instance_double(
          'Formatron::Formatronfile::Dependency'
        ),
        'dependency2' => instance_double(
          'Formatron::Formatronfile::Dependency'
        )
      }
      @dependencies.each do |key, instance|
        expect(dependency_class).to receive(:new).once.with(
          aws: aws,
          bucket: 'bucket',
          target: target,
          name: key
        ) { instance }
      end

      bootstrap_class = class_double(
        'Formatron::Formatronfile::Bootstrap'
      ).as_stubbed_const
      @bootstrap = double
      expect(bootstrap_class).to receive(:new).once.with(
        no_args
      ) { @bootstrap }
      expect(@bootstrap). to receive(:test).once.with(
        target,
        config,
        @dependencies
      )

      @formatronfile = Formatronfile.new(
        aws: aws,
        target: target,
        config: config,
        file: file
      )
    end

    describe '#depends' do
      it 'should add to the dependencies hash' do
        expect(@formatronfile.dependencies).to eql @dependencies
      end
    end

    describe '#bootstrap' do
      it 'should set the bootstrap property' do
        expect(@formatronfile.bootstrap).to eql @bootstrap
      end
    end

    describe '#name' do
      it 'should set the name property' do
        expect(@formatronfile.name).to eql 'name'
      end
    end

    describe '#bucket' do
      it 'should set the bucket property' do
        expect(@formatronfile.bucket).to eql 'bucket'
      end
    end
  end
end
