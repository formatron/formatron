require 'erb'
require 'fileutils'

TEMPLATE_DIR = File.expand_path('../../template', File.dirname(__FILE__))
ERB_TEMPLATES = %w(
  cloudformation/main.json
  Formatronfile
  README.md
)

class Formatron
  class Init

    def initialize (dir = nil)
      dir = Dir.pwd if dir.nil?
      @dest = File.expand_path dir
      @name = File.basename(@dest)
    end

    def write
      FileUtils.mkdir_p @dest
      files = Dir.glob(File.join(TEMPLATE_DIR, '*'), File::FNM_DOTMATCH)
      files = files.select {|file| file unless [File.join(TEMPLATE_DIR, '.'), File.join(TEMPLATE_DIR, '..')].include?(file)}
      FileUtils.cp_r files, @dest
      ERB_TEMPLATES.each do |template|
        filename = File.join(@dest, template)
        erb = ERB.new(File.read(filename))
        erb.filename = filename
        template = erb.def_class(TemplateParams, 'render()')
        File.write filename, template.new(@name).render()
      end
    end

    class TemplateParams
      def initialize(name)
        @name = name
      end
    end

  end
end
