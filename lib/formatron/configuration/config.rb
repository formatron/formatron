class Formatron
  class Configuration
    # Processes the config directory
    module Config
      def self.targets(directory)
        config = File.join directory, 'config'
        Dir.entries(config).select do |entry|
          path = File.join config, entry
          File.directory?(path) && !%w(_default . ..).include?(entry)
        end
      end

      def self.target(_directory, _target)
      end
    end
  end
end
