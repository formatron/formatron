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
        dsl_cls:
      )
        @results[tag] = []
        @dsl_instances[tag] = {}
        template_class = class_double(template_cls).as_stubbed_const(
          transfer_nested_constants: true
        )
        (0..9).each do |index|
          value = "#{tag}#{index}"
          @results[tag][index] = value
          template_instance = instance_double template_cls
          dsl_instance = instance_double dsl_cls
          allow(template_class).to receive(:new).with(
            tag => dsl_instance,
            **args
          ) { template_instance }
          allow(template_instance).to receive(:merge) do |resources:, outputs:|
            resources[tag] ||= []
            resources[tag][index] = value
            outputs[tag] ||= []
            outputs[tag][index] = value
          end
          @dsl_instances[tag][value] =
            dsl_instance
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
