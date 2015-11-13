class Formatron
  module Util
    # utilities for generating DSL classes
    module DSL
      def dsl_initialize_block(&block)
        define_method :initialize do |**params|
          instance_exec(**params, &block) unless block.nil?
        end
      end

      def dsl_initialize_hash(&block)
        attr_reader :dsl_key
        define_method :initialize do |dsl_key:, **params|
          @dsl_key = dsl_key
          instance_exec(
            dsl_key: dsl_key,
            **params,
            &block
          ) unless block.nil?
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
              value = self.class.const_get(cls).new
              instance_variable_set iv, value
            end
            block.call value
          end
          instance_variable_get iv
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def dsl_hash(symbol, cls, param_symbols = [])
        iv = "@#{symbol}"
        define_method symbol do |dsl_key = nil, &block|
          hash = instance_variable_get(iv)
          if hash.nil?
            hash = {}
            instance_variable_set iv, hash
          end
          unless dsl_key.nil?
            params = param_symbols.each_with_object({}) do |s, p|
              p[s] = instance_variable_get "@#{s}"
            end
            value = self.class.const_get(cls).new(
              dsl_key: dsl_key,
              **params
            )
            hash[dsl_key] = value
            block.call value unless block.nil?
          end
          hash
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def dsl_array(symbol)
        iv = "@#{symbol}"
        define_method symbol do |value = nil|
          array = instance_variable_get(iv)
          if array.nil?
            array = []
            instance_variable_set iv, array
          end
          array.push value unless value.nil?
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
            value = self.class.const_get(cls).new
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
