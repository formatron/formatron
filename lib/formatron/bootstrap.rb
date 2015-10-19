module Formatron
  # generates a bootstrap configuration
  module Bootstrap
    def self.generate(target_directory, name, hosted_zone_id)
      FileUtils.mkdir_p target_directory
      formatronfile = File.join target_directory, 'Formatronfile'
      File.write formatronfile, <<-EOH.gsub(/^ {8}/, '').strip
        name '#{name}'

        bootstrap do
          hosted_zone_id '#{hosted_zone_id}'
        end
      EOH
    end
  end
end
