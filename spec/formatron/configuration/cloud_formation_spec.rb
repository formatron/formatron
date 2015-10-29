require 'spec_helper'
require 'formatron/configuration/formatronfile'
require 'formatron/configuration/cloud_formation'

class Formatron
  # namespacing for tests
  class Configuration
    describe CloudFormation do
      include FakeFS::SpecHelpers

      name = 'name'
      bucket = 'bucket'
      bootstrap = 'bootstrap'
      dir = File.expand_path(
        File.join(
          File.dirname(File.expand_path(__FILE__)),
          '../../../lib/formatron/configuration/cloud_formation'
        )
      )

      before :each do
        FileUtils.mkdir_p dir
      end

      context 'with a bootstrap configuration' do
        before(:each) do
          File.write(
            File.join(dir, 'bootstrap.json.erb'),
            <<-EOH.gsub(/^ {14}/, '')
              <%= name %>
              <%= bucket %>
              <%= configuration %>
            EOH
          )
          @formatronfile = instance_double(
            'Formatron::Configuration::Formatronfile'
          )
          allow(@formatronfile).to receive(:name) { name }
          allow(@formatronfile).to receive(:bucket) { bucket }
          allow(@formatronfile).to receive(:bootstrap) { bootstrap }
        end

        describe '::template' do
          it 'should return the CloudFormation template for ' \
             'a Formatron configuration' do
            expect(
              CloudFormation.template(
                @formatronfile
              )
            ).to eql <<-EOH.gsub(/^ {14}/, '')
              #{name}
              #{bucket}
              #{bootstrap}
            EOH
          end
        end
      end
    end
  end
end
