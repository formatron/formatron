class Formatron
  class Config
    # loads config and stack outputs from dependency
    class Depends
      def initialize(s3_client, cloudformation_client)
        @s3_client = s3_client
        @cloudformation_client = cloudformation_client
      end

      def load(s3_bucket, prefix, stack_name, target, config)
        response = @s3_client.get_object(
          bucket: s3_bucket,
          key: "#{target}/#{stack_name}/config.json"
        )
        base = JSON.parse(response.body.read)
        config = base.deep_merge!(config)
        load_outputs prefix, stack_name, target, config
        config
      end

      def load_outputs(prefix, stack_name, target, config)
        return if config[stack_name]['formatronOutputs'].nil?
        full_stack_name = "#{prefix}-#{stack_name}-#{target}"
        response = @cloudformation_client.describe_stacks(
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
