class Formatron
  class Config
    # loads config and stack outputs from dependency
    class Depends
      def initialize(credentials)
        @credentials = credentials
      end

      def load(prefix, stack_name, target, config)
        s3 = Aws::S3::Client.new(
          region: region,
          signature_version: 'v4',
          credentials: @credentials
        )
        response = s3.get_object(
          bucket: s3_bucket,
          key: "#{target}/#{stack_name}/config.json"
        )
        base = JSON.parse(response.body.read)
        config = base.deep_merge!(config)
        load_outputs prefix, stack_name, target
        config
      end

      def load_outputs(prefix, stack_name, target)
        return if config[stack_name]['formatronOutputs'].nil?
        full_stack_name = "#{prefix}-#{stack_name}-#{target}"
        cloudformation = Aws::CloudFormation::Client.new(
          region: region,
          credentials: @credentials
        )
        response = cloudformation.describe_stacks(
          stack_name: full_stack_name
        )
        stack = response.stacks[0]
        fail "Stack dependency not ready: #{full_stack_name}" unless %w(
          CREATE_COMPLETE
          ROLLBACK_COMPLETE
          UPDATE_COMPLETE
          UPDATE_ROLLBACK_COMPLETE
        ).include? stack.stack_status
        outputs = config[stack_name]['formatronOutputs']
        stack.outputs.each do |output|
          outputs[output.output_key] = output.output_value
        end
      end
    end
  end
end
