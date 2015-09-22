class Formatron
  # reads a Formatronfile
  class Formatronfile
    def initialize(file)
      @depends = []
      instance_eval(File.read(file), file)
    end

    def name(value = nil)
      @name = value unless value.nil?
      @name
    end

    def s3_bucket(value = nil)
      @s3_bucket = value unless value.nil?
      @s3_bucket
    end

    def prefix(value = nil)
      @prefix = value unless value.nil?
      @prefix
    end

    def kms_key(value = nil)
      @kms_key = value unless value.nil?
      @kms_key
    end

    def depends(value = nil)
      @depends.push(value) unless value.nil?
      @depends
    end

    def cloudformation(&block)
      @cloudformation = block if block_given?
      @cloudformation
    end

    def opscode(&block)
      @opscode = block if block_given?
      @opscode
    end
  end
end
