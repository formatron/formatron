require 'spec_helper'
require 'curb'

require 'formatron/generators/instance'

class Formatron
  # rubocop:disable Metrics/ModuleLength
  module Generators
    describe Instance do
      include FakeFS::SpecHelpers

      directory = 'test/directory'
      params = {
        name: 'name',
        instance_name: 'instance_name',
        s3_bucket: 's3_bucket',
        bootstrap_configuration: 'bootstrap',
        vpc: 'vpc',
        subnet: 'subnet',
        targets: %w(target1 target2)
      }
      instance_guid = 'instance_guid'

      describe '::generate' do
        before(:each) do
          lib = File.expand_path(
            File.join(
              File.dirname(File.expand_path(__FILE__)),
              '../../../lib'
            )
          )
          FakeFS::FileSystem.clone lib
          util_class = class_double(
            'Formatron::Generators::Util'
          ).as_stubbed_const transfer_nested_constants: true
          allow(util_class).to receive(:guid) do
            instance_guid
          end
          Instance.generate directory, params
        end

        it 'should generate a README.md' do
          actual = File.read File.join(directory, 'README.md')
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            # #{params[:name]}

            Formatron configuration
          EOH
        end

        it 'should generate a .gitignore' do
          actual = File.read File.join(directory, '.gitignore')
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            /.formatron/
          EOH
        end

        it 'should generate a Formatronfile' do
          actual = File.read File.join(directory, 'Formatronfile')
          # rubocop:disable Metrics/LineLength
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            formatron.name '#{params[:name]}'
            formatron.bucket '#{params[:s3_bucket]}'

            formatron.depends '#{params[:bootstrap_configuration]}'

            formatron.vpc '#{params[:vpc]}' do |vpc|
              vpc.subnet '#{params[:subnet]}' do |subnet|
                subnet.instance '#{params[:instance_name]}' do |instance|
                  instance.guid 'instance#{instance_guid}'
                  instance.sub_domain config['#{params[:instance_name]}']['sub_domain']
                  instance.chef do |chef|
                    chef.cookbook 'cookbooks/#{params[:instance_name]}_instance'
                  end
                end
              end
            end
          EOH
          # rubocop:enable Metrics/LineLength
        end

        it 'should generate a config stub for each target' do
          actual = File.read File.join(
            directory,
            'config/_default/_default.json'
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            {
            }
          EOH
          actual = File.read File.join(
            directory,
            'config/target1/_default.json'
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            {
              "#{params[:instance_name]}": {
                "sub_domain": "#{params[:instance_name]}-target1"
              }
            }
          EOH
          actual = File.read File.join(
            directory,
            'config/target2/_default.json'
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            {
              "#{params[:instance_name]}": {
                "sub_domain": "#{params[:instance_name]}-target2"
              }
            }
          EOH
        end

        it 'should add an instance cookbook stub' do
          actual = File.read File.join(
            directory,
            "cookbooks/#{params[:instance_name]}_instance/metadata.rb"
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            name '#{params[:instance_name]}_instance'
            version '0.1.0'
            supports 'ubuntu'
          EOH
          actual = File.read File.join(
            directory,
            "cookbooks/#{params[:instance_name]}_instance/Berksfile"
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            source 'https://supermarket.chef.io'

            metadata
          EOH
          actual = File.read File.join(
            directory,
            "cookbooks/#{params[:instance_name]}_instance/README.md"
          )
          # rubocop:disable Metrics/LineLength
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
            # #{params[:instance_name]}_instance

            Cookbook to perform additional configuration on the #{params[:instance_name]} instance
          EOH
          # rubocop:enable Metrics/LineLength
          actual = File.read File.join(
            directory,
            "cookbooks/#{params[:instance_name]}_instance/recipes/default.rb"
          )
          expect(actual).to eql <<-EOH.gsub(/^ {12}/, '')
          EOH
        end
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
