class Formatron
  class Formatronfile
    class Bootstrap
      # EC2 key pair configuration
      class EC2
        %i(
          key_pair
          private_key
        ).each do |symbol|
          define_method symbol do |value = nil|
            instance_variable_set "@#{symbol}", value unless value.nil?
            instance_variable_get "@#{symbol}"
          end
        end
      end
    end
  end
end
