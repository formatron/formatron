require 'rubygems'
require 'rubygems/package'
require 'zlib'

module FormatronUtil
  module Tar
    def tar(path)
      tarfile = StringIO.new('')
      Gem::Package::TarWriter.new(tarfile) do |tar|
        Dir.glob(File.join(path, '**/*'), File::FNM_DOTMATCH).each do |file|
          next if ['.', '..'].include?(File.basename(file))
          mode = File.stat(file).mode
          relative_file = file.sub(%r{^#{Regexp.escape path}/?}, '')
          if File.directory?(file)
            tar.mkdir relative_file, mode
          else
            tar.add_file relative_file, mode do |tf|
              File.open(file, 'rb') { |f| tf.write f.read }
            end
          end
        end
      end

      tarfile.rewind
      tarfile
    end

    def gzip(tarfile)
      gz = StringIO.new('')
      z = Zlib::GzipWriter.new(gz)
      z.write tarfile.string
      z.close
      # z was closed to write the gzip footer, so
      # now we need a new StringIO
      StringIO.new gz.string
    end
  end
end
