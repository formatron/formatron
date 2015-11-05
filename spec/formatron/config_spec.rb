require 'spec_helper'
require 'json'
require 'formatron/config'

# namespacing for tests
class Formatron
  describe Config do
    include FakeFS::SpecHelpers

    directory = 'test/configuration'
    targets = %w(target1 target2 target3)
    default_config = {
      'param1' => 'param1 default',
      'param2' => 'param2 default'
    }
    target_config = {}
    merged_config = {}
    targets.each do |target|
      target_config[target] = {
        'param2' => "param2 #{target}",
        'param3' => "param3 #{target}"
      }
      merged_config[target] = {
        'param1' => 'param1 default',
        'param2' => "param2 #{target}",
        'param3' => "param3 #{target}"
      }
    end

    before(:each) do
      default_dir = File.join directory, 'config', '_default'
      FileUtils.mkdir_p default_dir
      File.write File.join(default_dir, '_default.json'), default_config.to_json
      targets.each do |target|
        target_dir = File.join directory, 'config', target
        FileUtils.mkdir_p target_dir
        File.write File.join(
          target_dir, '_default.json'
        ), target_config[target].to_json
      end
    end

    describe '::targets' do
      it 'should return the targets defined in the config directory' do
        expect(Config.targets(directory: directory)).to eql(
          targets
        )
      end
    end

    describe '::target' do
      it 'should return the merged target configuration ' \
         'from the config directory' do
        targets.each do |target|
          expect(
            Config.target(
              directory: directory,
              target: target
            )
          ).to eql merged_config[target]
        end
      end
    end
  end
end
