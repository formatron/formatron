require 'rubygems'
require 'rubygems/package'
require 'zlib'

class Formatron
  module Util
    # Tar and Gzip in memory implementations
    module Tar
      def self.tar(path)
        tarfile = StringIO.new('')
        Gem::Package::TarWriter.new(tarfile) do |tar|
          _tar_files tar, path
        end
        tarfile.rewind
        tarfile
      end

      def self._tar_files(tar, path)
        Dir.glob(File.join(path, '**/*'), File::FNM_DOTMATCH).each do |file|
          next if ['.', '..'].include?(File.basename(file))
          _tar_entry tar, file, path
        end
      end

      def self._tar_entry(tar, file, path)
        relative_file = file.sub(%r{^#{Regexp.escape path}/?}, '')
        mode = File.stat(file).mode
        if File.directory?(file)
          _tar_directory tar, relative_file, mode
        else
          _tar_file tar, file, relative_file, mode
        end
      end

      def self._tar_directory(tar, relative_file, mode)
        puts relative_file
        tar.mkdir relative_file, mode
      end

      def self._tar_file(tar, file, relative_file, mode)
        puts file
        puts relative_file
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

      private_class_method(
        :_tar_files,
        :_tar_entry,
        :_tar_directory,
        :_tar_file
      )
    end
  end
end
