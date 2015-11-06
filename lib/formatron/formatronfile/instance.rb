class Formatron
  class Formatronfile
    # Generic instance configuration
    class Instance
      %i(
        subnet
        sub_domain
        cookbook
      ).each do |symbol|
        define_method symbol do |value = nil|
          instance_variable_set "@#{symbol}", value unless value.nil?
          instance_variable_get "@#{symbol}"
        end
      end
    end
  end
end
