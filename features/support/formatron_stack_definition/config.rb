class Formatron::Features::Support::FormatronStackDefinition::Config
  CONFIG_DIR = 'config'
  DEFAULT_FILE = '_default.json'

  def initialize(dir, target, param)
    config_dir = File.join(dir, CONFIG_DIR, target)
    FileUtils.mkdir_p config_dir
    File.write File.join(config_dir, DEFAULT_FILE), <<-EOH.gsub(/^ {6}/, '')
      {
        "param" = "#{param}"
      }
    EOH
  end
end
