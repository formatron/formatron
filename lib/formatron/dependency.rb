class Formatron
  # loads config and stack outputs from dependency
  class Dependency
    attr_reader :hash

    def initialize(aws, params)
      response = aws.s3_client.get_object(
        bucket: params[:s3_bucket],
        key: "#{params[:target]}/#{params[:name]}/config.json"
      )
      @hash = JSON.parse(response.body.read)
      load_outputs(
        aws.cloudformation_client,
        params[:prefix],
        params[:name],
        params[:target]
      )
    end

    def load_outputs(cloudformation_client, prefix, stack_name, target)
      return if @hash['stacks'][stack_name]['outputs'].nil?
      full_stack_name = "#{prefix}-#{stack_name}-#{target}"
      response = cloudformation_client.describe_stacks(
        stack_name: full_stack_name
      )
      stack = response.stacks[0]
      fail "Stack dependency not ready: #{full_stack_name}" unless %w(
        CREATE_COMPLETE
        ROLLBACK_COMPLETE
        UPDATE_COMPLETE
        UPDATE_ROLLBACK_COMPLETE
      ).include? stack.stack_status
      outputs = @hash['stacks'][stack_name]['outputs']
      stack.outputs.each do |output|
        outputs[output.output_key] = output.output_value
      end
    end
  end
end
