class Formatron
  # defines the S3 bucket keys for consistency
  module S3Path
    def self.path(configuration, target, sub_path)
      File.join _base_path(configuration, target), sub_path
    end

    def self._base_path(configuration, target)
      File.join target, configuration.name(target)
    end

    private_class_method(
      :_base_path
    )
  end
end
