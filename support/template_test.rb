class Formatron
  module Support
    # utilities for testing CloudFormation template classes
    module TemplateTest
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def test_instances(
        tag:,
        args: {},
        template_cls:,
        formatronfile_cls:
      )
        @results[tag] = []
        @formatronfile_instances[tag] = {}
        template_class = class_double(template_cls).as_stubbed_const
        (0..9).each do |index|
          value = "#{tag}#{index}"
          @results[tag][index] = value
          template_instance = instance_double template_cls
          formatronfile_instance = instance_double formatronfile_cls
          allow(template_class).to receive(:new).with(
            tag => formatronfile_instance,
            **args
          ) { template_instance }
          allow(template_instance).to receive(:merge) do |resources:, outputs:|
            resources[tag] ||= []
            resources[tag][index] = value
            outputs[tag] ||= []
            outputs[tag][index] = value
          end
          @formatronfile_instances[tag][value] =
            formatronfile_instance
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
