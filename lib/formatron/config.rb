require_relative 'config/reader'
require 'deep_merge'

class Formatron
  # Processes the config directory
  module Config
    CONFIG_DIR = 'config'
    DEFAULT_CONFIG = '_default'
    DEFAULT_JSON = '_default.json'

    def self.targets(directory:)
      config = File.join directory, CONFIG_DIR
      Dir.entries(config).select do |entry|
        path = File.join config, entry
        File.directory?(path) && !%W(#{DEFAULT_CONFIG} . ..).include?(entry)
      end
    end

    def self.target(directory:, target:)
      Reader.read(
        File.join(directory, CONFIG_DIR, DEFAULT_CONFIG),
        DEFAULT_JSON
      ).deep_merge!(
        Reader.read(
          File.join(directory, CONFIG_DIR, target),
          DEFAULT_JSON
        )
      )
    end
  end
end
