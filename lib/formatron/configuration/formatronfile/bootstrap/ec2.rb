class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # EC2 key pair configuration
        class EC2
          def key_pair(value = nil)
            @key_pair = value unless value.nil?
            @key_pair
          end

          def private_key(value = nil)
            @private_key = value unless value.nil?
            @private_key
          end
        end
      end
    end
  end
end
