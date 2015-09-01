class Formatron::Features::Support::FormatronStackDefinition::Formatronfile
  FORMATRONFILE_NAME = 'Formatronfile'

  def initialize(dir, prefix, name, s3_bucket, region, test_target, test_kms_key, prod_target, prod_kms_key)
    File.write File.join(dir, FORMATRONFILE_NAME), <<-EOH.gsub(/^ {6}/, '')
      name '#{name}'
      prefix '#{prefix}'
      s3_bucket '#{s3_bucket}'
      region '#{region}'
      kms_key '#{test_target}', '#{test_kms_key}'
      kms_key '#{prod_target}', '#{prod_kms_key}'
      cloudformation do
        parameter 'param', config['#{name}']['param']
      end
    EOH
  end
end
