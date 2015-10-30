require 'spec_helper'
require 'formatron/configuration/formatronfile/dsl'

class Formatron
  class Configuration
    # namespacing for tests
    class Formatronfile
      describe DSL do
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
            'Formatron::Configuration::Formatronfile::Dependency'
          ).as_stubbed_const
          @dependencies = {
            'dependency1' => instance_double(
              'Formatron::Configuration::Formatronfile::Dependency'
            ),
            'dependency2' => instance_double(
              'Formatron::Configuration::Formatronfile::Dependency'
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
            'Formatron::Configuration::Formatronfile::Bootstrap'
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

          @dsl = Formatron::Configuration::Formatronfile::DSL.new(
            aws: aws,
            target: target,
            config: config,
            file: file
          )
        end

        describe '#depends' do
          it 'should add to the dependencies hash' do
            expect(@dsl.dependencies).to eql @dependencies
          end
        end

        describe '#bootstrap' do
          it 'should set the bootstrap property' do
            expect(@dsl.bootstrap).to eql @bootstrap
          end
        end

        describe '#name' do
          it 'should set the name property' do
            expect(@dsl.name).to eql 'name'
          end
        end

        describe '#bucket' do
          it 'should set the bucket property' do
            expect(@dsl.bucket).to eql 'bucket'
          end
        end
      end
    end
  end
end
