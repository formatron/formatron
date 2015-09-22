require 'formatron/config'
require 'formatron/dependency'
require 'formatron/aws'
require 'formatron/cloudformation'
require 'formatron/formatronfile'
require 'formatron/opscode'

class Formatron
  # The Formatron project loader
  class Project
    attr_reader :config, :cloudformation, :opscode

    FORMATRON_FILE = 'Formatronfile'
    CONFIG_DIR = 'config'
    CREDENTIALS_JSON = 'credentials.json'

    def initialize(dir, target)
      aws = Formatron::Aws.new(
        File.join(dir, CREDENTIALS_JSON)
      )
      formatronfile = Formatron::Formatronfile.new(
        File.join(dir, FORMATRON_FILE)
      )
      s3_bucket = formatronfile.s3_bucket
      prefix = formatronfile.prefix
      cloudformation = formatronfile.cloudformation
      opscode = formatronfile.opscode
      @config = Formatron::Config.new(
        {
          name: formatronfile.name,
          target: target,
          s3_bucket: s3_bucket,
          prefix: prefix,
          kms_key: formatronfile.kms_key
        },
        File.join(dir, CONFIG_DIR),
        formatronfile.depends.map do |dependency|
          Formatron::Dependency.new(
            aws,
            name: dependency,
            target: target,
            s3_bucket: s3_bucket,
            prefix: prefix
          )
        end,
        cloudformation.nil? ? false : true
      )
      @cloudformation = Formatron::Cloudformation.new(
        @config, cloudformation
      ) unless cloudformation.nil?
      @opscode = Formatron::Opscode.new(
        @config, opscode
      ) unless opscode.nil?
    end
  end
end
