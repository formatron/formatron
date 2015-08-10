require 'json'

class AwsDeploy::Config::Reader

  def self.read (dir, default_file)
    default = File.join(dir, default_file)
    config = File.file?(default) ? JSON.parse(File.read(default)) : {}
    entries = Dir.entries(dir)
    entries.each do |entry|
      path = File.join(dir, entry)
      next if ['.', '..', default_file].include?(entry)
      config[entry] = compose_config(path) if File.directory?(path)
      config[entry] = File.read(path) if File.file?(path)
    end
    config
  end

end
