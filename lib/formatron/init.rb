require 'erb'
require 'fileutils'

TEMPLATE_DIR = File.expand_path('../../template', File.dirname(__FILE__))
ERB_TEMPLATES = %w(
  cloudformation/main.json.erb
  Formatronfile
  README.md
)

class Formatron
  # Initialise a new Formatron project
  class Init
    def initialize(dir = nil)
      dir = Dir.pwd if dir.nil?
      @dest = File.expand_path dir
      @name = File.basename(@dest)
    end

    def write
      FileUtils.mkdir_p @dest
      files = Dir.glob(File.join(TEMPLATE_DIR, '*'), File::FNM_DOTMATCH)
      ignore_files = [
        File.join(TEMPLATE_DIR, '.'),
        File.join(TEMPLATE_DIR, '..')
      ]
      files = files.select do |file|
        file unless ignore_files.include?(file)
      end
      FileUtils.cp_r files, @dest
      write_templates
    end

    def write_templates
      ERB_TEMPLATES.each do |template|
        filename = File.join(@dest, template)
        erb = ERB.new(File.read(filename))
        erb.filename = filename
        template = erb.def_class(TemplateParams, 'render()')
        File.write filename, template.new(@name).render
      end
    end

    # Internal class for holding parameters to expose to template
    class TemplateParams
      def initialize(name)
        @name = name
      end
    end
  end
end
