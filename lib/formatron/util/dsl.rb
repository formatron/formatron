class Formatron
  module Util
    # utilities for generating DSL classes
    module DSL
      def dsl_initialize_block
        attr_reader :dsl_parent
        define_method :initialize do |parent:|
          @dsl_parent = parent
        end
      end

      def dsl_initialize_hash
        attr_reader :dsl_parent, :dsl_key
        define_method :initialize do |parent:, key:|
          @dsl_parent = parent
          @dsl_key = key
        end
      end

      def dsl_property(symbol)
        iv = "@#{symbol}"
        define_method symbol do |value = nil|
          instance_variable_set iv, value unless value.nil?
          instance_variable_get iv
        end
      end

      # rubocop:disable Metrics/MethodLength
      def dsl_block(symbol, cls)
        iv = "@#{symbol}"
        define_method symbol do |&block|
          unless block.nil?
            value = instance_variable_get(iv)
            if value.nil?
              value = self.class.const_get(cls).new parent: self
              instance_variable_set iv, value
            end
            block.call value
          end
          instance_variable_get iv
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def dsl_hash(symbol, cls)
        iv = "@#{symbol}"
        define_method symbol do |key = nil, &block|
          hash = instance_variable_get(iv)
          if hash.nil?
            hash = {}
            instance_variable_set iv, hash
          end
          unless key.nil?
            value = self.class.const_get(cls).new(
              key: key,
              parent: self
            )
            hash[key] = value
            block.call value unless block.nil?
          end
          hash
        end
      end
      # rubocop:enable Metrics/MethodLength

      def dsl_array(symbol)
        iv = "@#{symbol}"
        define_method symbol do |key = nil|
          array = instance_variable_get(iv)
          if array.nil?
            array = []
            instance_variable_set iv, array
          end
          array.push key unless key.nil?
          array
        end
      end

      # rubocop:disable Metrics/MethodLength
      def dsl_block_array(symbol, cls)
        iv = "@#{symbol}"
        define_method symbol do |&block|
          array = instance_variable_get(iv)
          if array.nil?
            array = []
            instance_variable_set iv, array
          end
          unless block.nil?
            value = self.class.const_get(cls).new(
              parent: self
            )
            array.push value
            block.call value
          end
          array
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
