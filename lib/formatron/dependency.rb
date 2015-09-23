class Formatron
  # loads config and stack outputs from dependency
  class Dependency
    attr_reader :hash

    READY_STATES = %w(
      CREATE_COMPLETE
      ROLLBACK_COMPLETE
      UPDATE_COMPLETE
      UPDATE_ROLLBACK_COMPLETE
    )

    def initialize(aws, params)
      _get_config_from_s3 aws, params
      return if @hash['stacks'][params[:name]]['outputs'].nil?
      _get_outputs_from_cloudformation aws, params
    end

    def _get_config_from_s3(aws, params)
      response = aws.s3_client.get_object(
        bucket: params[:s3_bucket],
        key: "#{params[:target]}/#{params[:name]}/config.json"
      )
      @hash = JSON.parse(response.body.read)
    end

    def _get_outputs_from_cloudformation(aws, params)
      full_stack_name = "#{params[:prefix]}-#{params[:name]}-#{params[:target]}"
      stack = _describe_stack(aws.cloudformation_client, full_stack_name)
      unless READY_STATES.include? stack.stack_status
        fail "Stack dependency not ready: #{full_stack_name}"
      end
      _apply_outputs @hash['stacks'][params[:name]]['outputs'], stack
    end

    def _describe_stack(cloudformation_client, stack_name)
      response = cloudformation_client.describe_stacks(
        stack_name: stack_name
      )
      response.stacks[0]
    end

    def _apply_outputs(outputs, stack)
      stack.outputs.each do |output|
        outputs[output.output_key] = output.output_value
      end
    end

    private(
      :_get_config_from_s3,
      :_get_outputs_from_cloudformation,
      :_describe_stack,
      :_apply_outputs
    )
  end
end
