require 'spec_helper'

require 'formatron/bootstrap'

describe Formatron::Bootstrap do
  include FakeFS::SpecHelpers

  name = 'bootstrap'
  target_directory = 'test/directory'
  hosted_zone_id = 'HOSTEDZONEID'

  context "with a target directory of #{target_directory}, " \
          "name of #{name} and " \
          "hosted zone ID of #{hosted_zone_id}" do
    describe '::generate' do
      it 'should generate the initial Formatronfile' do
        Formatron::Bootstrap.generate target_directory, name, hosted_zone_id
        actual = File.read File.join(target_directory, 'Formatronfile')
        expect(actual).to eql <<-EOH.gsub(/^ {10}/, '')
          name '#{name}'

          bootstrap do
            hosted_zone_id '#{hosted_zone_id}'
          end
        EOH
      end
    end
  end
end
