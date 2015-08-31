class Formatron::Features::Support::FormatronStackDefinition::Formatronfile
  FORMATRONFILE_NAME = 'Formatronfile'

  def initialize(dir, prefix, name, s3_bucket)
    File.write File.join(dir, FORMATRONFILE_NAME), <<-EOH.gsub(/^ {6}/, '')
      name '#{name}'
      prefix '#{prefix}'
      s3_bucket '#{s3_bucket}'
      region 'eu-west-1'
      cloudformation do
        parameter 'param', config['#{name}']['param']
      end
    EOH
  end
end
