class Formatron
  module Generators
    # generates a credentials JSON file
    module Credentials
      def self.generate(file, region, access_key_id, secret_access_key)
        FileUtils.mkdir_p File.dirname(file)
        File.write file, <<-EOH.gsub(/^ {10}/, '')
          {
            "region": "#{region}",
            "access_key_id": "#{access_key_id}",
            "secret_access_key": "#{secret_access_key}"
          }
        EOH
      end
    end
  end
end
