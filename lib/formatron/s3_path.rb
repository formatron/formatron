class Formatron
  # defines the S3 bucket keys for consistency
  module S3Path
    def self.key(name:, target:, sub_key:)
      File.join _base_path(
        name: name,
        target: target
      ), sub_key
    end

    def self.url(region:, bucket:, name:, target:, sub_key:)
      key = key(
        name: name,
        target: target,
        sub_key: sub_key
      )
      "https://s3-#{region}.amazonaws.com/#{bucket}/#{key}"
    end

    def self._base_path(name:, target:)
      File.join target, name
    end

    private_class_method(
      :_base_path
    )
  end
end
