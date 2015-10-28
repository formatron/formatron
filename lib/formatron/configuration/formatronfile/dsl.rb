class Formatron
  class Configuration
    class Formatronfile
      # DSL for the Formatronfile
      class DSL
        def initialize(_target, _config, file)
          instance_eval File.read(file), file
        end

        def bootstrap(&block)
          @bootstrap = block if block_given?
          @bootstrap
        end

        def name(value = nil)
          @name = value unless value.nil?
          @name
        end

        def bucket(value = nil)
          @bucket = value unless value.nil?
          @bucket
        end
      end
    end
  end
end
