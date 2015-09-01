class Formatron::Features::Support::FormatronStackDefinition::Config
  attr_reader :json

  CONFIG_DIR = 'config'
  DEFAULT_FILE = '_default.json'
  JSON = <<-EOH.gsub(/^ {4}/, '')
    {
      "param": "%{param}"
    }
  EOH

  def initialize(dir, target, param)
    config_dir = File.join(dir, CONFIG_DIR, target)
    FileUtils.mkdir_p config_dir
    @json = JSON % { param: param }
    File.write File.join(config_dir, DEFAULT_FILE), json
  end
end
