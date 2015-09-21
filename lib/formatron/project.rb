require 'formatron/config'
require 'formatron/dependency'

class Formatron
  # The Formatron project loader
  class Project
    attr_reader :config
    attr_writer :name, :s3_bucket, :prefix, :kms_key

    FORMATRON_FILE = 'Formatronfile'
    CONFIG_DIR = 'config'

    class Error < RuntimeError
    end

    def initialize(dir)
      fail Error, "#{dir} is not a directory" unless File.directory? dir
      formatronfile = File.join(dir, FORMATRON_FILE)
      fail Error, 'Formatronfile not found' unless File.file? formatronfile
      @dependencies = []
      instance_eval(File.read(formatronfile), formatronfile)
      @config = Formatron::Config.new(
        @name, {
          s3_bucket: @s3_bucket,
          prefix: @prefix,
          kms_key: @kms_key
        },
        File.join(dir, CONFIG_DIR),
        @dependencies.map { |dependency| Formatron::Dependency.new(dependency) }
      )
    end

    def name(value)
      self.name = value
    end

    def s3_bucket(value)
      self.s3_bucket = value
    end

    def prefix(value)
      self.prefix = value
    end

    def kms_key(value)
      self.kms_key = value
    end

    def depends(dependency)
      @dependencies.push(dependency)
    end
  end
end
