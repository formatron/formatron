require 'json'
require 'deep_merge'

class Formatron
  module Config
    # reads config directories into config hash
    module Reader
      def self.read(dir, default_file)
        default = File.join(dir, default_file)
        config = File.file?(default) ? JSON.parse(File.read(default)) : {}
        entries = Dir.glob(File.join(dir, '*'), File::FNM_DOTMATCH)
        do_entries entries, default_file, config
        config
      end

      def self.do_entries(entries, default_file, config)
        entries.each do |entry|
          basename = File.basename(entry)
          next if ['.', '..', default_file].include?(basename)
          config[basename] = {} unless config[basename].is_a? Hash
          config[basename].deep_merge!(
            read(entry, default_file)
          ) if File.directory?(entry)
          config[basename] = File.read(entry) if File.file?(entry)
        end
      end
    end
  end
end
