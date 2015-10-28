class Formatron
  class Configuration
    class Formatronfile
      # DSL for the Formatronfile
      class DSL
        attr_reader(
          :name,
          :bucket
        )

        def initialize(scope, file)
          scope.each do |key, value|
            self.class.send(:define_method, key, proc { value })
          end
          instance_eval File.read(file), file
        end

        def bootstrap(name: nil, bucket: nil, &block)
          @name = name unless name.nil?
          @bucket = bucket unless bucket.nil?
          @bootstrap = block if block_given?
          @bootstrap
        end
      end
    end
  end
end
