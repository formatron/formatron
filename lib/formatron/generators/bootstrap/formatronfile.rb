require 'erb'
require 'curb'
require 'formatron/generators/util'

class Formatron
  module Generators
    module Bootstrap
      # generates a bootstrap Formatronfile
      module Formatronfile
        # exports params to bootstrap ERB template
        class Template
          attr_reader :params, :ip

          def initialize(params)
            @params = params
            @ip = Curl.get('http://whatismyip.akamai.com').body_str
          end

          def guid
            Util.guid
          end

          def databag_secret
            Util.databag_secret
          end
        end

        def self.write(directory, params)
          FileUtils.mkdir_p directory
          formatronfile = File.join directory, 'Formatronfile'
          File.write formatronfile, _content(params)
        end

        def self._content(params)
          template = File.join(
            File.dirname(File.expand_path(__FILE__)),
            File.basename(__FILE__, '.rb'),
            'Formatronfile.erb'
          )
          erb = ERB.new File.read(template)
          erb.filename = template
          erb_template = erb.def_class Template, 'render()'
          erb_template.new(params).render
        end

        private_class_method(
          :_content
        )
      end
    end
  end
end
