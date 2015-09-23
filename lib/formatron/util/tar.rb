require 'rubygems'
require 'rubygems/package'
require 'zlib'

class Formatron
  module Util
    # Tar and Gzip in memory implementations
    module Tar
      # :nocov:
      def self.tar(path)
        tarfile = StringIO.new('')
        Gem::Package::TarWriter.new(tarfile) do |tar|
          tar_files tar, path
        end
        tarfile.rewind
        tarfile
      end

      def self.tar_files(tar, path)
        Dir.glob(File.join(path, '**/*'), File::FNM_DOTMATCH).each do |file|
          next if ['.', '..'].include?(File.basename(file))
          tar_entry tar, file, path
        end
      end

      def self.tar_entry(tar, file, path)
        relative_file = file.sub(%r{^#{Regexp.escape path}/?}, '')
        if File.directory?(file)
          tar_directory tar, relative_file
        else
          tar_file tar, file, relative_file
        end
      end

      def self.tar_directory(tar, relative_file)
        tar.mkdir relative_file, mode
      end

      def self.tar_file(tar, file, relative_file)
        mode = File.stat(file).mode
        tar.add_file relative_file, mode do |tf|
          File.open(file, 'rb') { |f| tf.write f.read }
        end
      end

      def self.gzip(tarfile)
        gz = StringIO.new('')
        z = Zlib::GzipWriter.new(gz)
        z.write tarfile.string
        z.close
        # z was closed to write the gzip footer, so
        # now we need a new StringIO
        StringIO.new gz.string
      end
      # :nocov:
    end
  end
end
