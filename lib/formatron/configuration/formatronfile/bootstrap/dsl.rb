class Formatron
  class Configuration
    class Formatronfile
      class Bootstrap
        # DSL for the Formatronfile bootstrap section
        class DSL
          def initialize(scope, block)
            scope.each do |key, value|
              self.class.send(:define_method, key, proc { value })
            end
            instance_eval(&block)
          end

          def protect(value = nil)
            @protect = value unless value.nil?
            @protect
          end

          def kms_key(value = nil)
            @kms_key = value unless value.nil?
            @kms_key
          end

          def hosted_zone_id(value = nil)
            @hosted_zone_id = value unless value.nil?
            @hosted_zone_id
          end

          def ec2(&block)
            @ec2 = block if block_given?
            @ec2
          end
        end
      end
    end
  end
end
