class Formatron
  # defines the S3 bucket keys for consistency
  module S3Path
    def self.path(configuration:, target:, sub_path:)
      File.join _base_path(
        configuration: configuration,
        target: target
      ), sub_path
    end

    def self.url(region:, configuration:, target:, sub_path:)
      key = path(
        configuration: configuration,
        target: target,
        sub_path: sub_path
      )
      bucket = configuration.bucket target
      "https://s3-#{region}.amazonaws.com/#{bucket}/#{key}"
    end

    def self._base_path(configuration:, target:)
      File.join target, configuration.name(target)
    end

    private_class_method(
      :_base_path
    )
  end
end
