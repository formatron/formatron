class Formatron
  class Configuration
    # Generates the CloudFormation templates
    module CloudFormation
      # exports params to CloudFormation ERB template
      class Template
        attr_reader :name, :bucket, :configuration

        def initialize(name:, bucket:, configuration:)
          @name = name
          @bucket = bucket
          @configuration = configuration
        end
      end

      def self.template(formatronfile)
        template = _template_path
        erb = ERB.new File.read(template)
        erb.filename = template
        erb_template = erb.def_class Template, 'render()'
        erb_template.new(
          name: formatronfile.name,
          bucket: formatronfile.bucket,
          configuration: formatronfile.bootstrap
        ).render
      end

      def self._template_path
        File.join(
          File.dirname(File.expand_path(__FILE__)),
          File.basename(__FILE__, '.rb'),
          'bootstrap.json.erb'
        )
      end

      private_class_method(
        :_template_path
      )
    end
  end
end
