class Formatron
  module Support
    # utilities for testing generated DSL classes
    module DSLTest
      def dsl_before_block(&block)
        before :each do
          params = {}
          params = instance_eval(&block) if block_given?
          @dsl_instance = described_class.new(**params)
        end
      end

      def dsl_before_hash(&block)
        before :each do
          params = {}
          params = instance_exec(&block) if block_given?
          @dsl_instance = described_class.new(
            'dsl_key', **params
          )
        end
      end

      def dsl_property(symbol)
        describe "##{symbol}" do
          it "should set the #{symbol}" do
            expect(@dsl_instance.send(symbol)).to be_nil
            @dsl_instance.send symbol, 'value'
            expect(@dsl_instance.send(symbol)).to eql 'value'
          end
        end
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def dsl_block(symbol, cls)
        describe "##{symbol}" do
          it "should set the #{symbol} and yield to the given block" do
            sub = double
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(sub).to receive(:test).with no_args
            expect(cls).to receive(:new).with(
              no_args
            ) { sub }
            expect(@dsl_instance.send(symbol)).to be_nil
            @dsl_instance.send symbol, &:test
            expect(@dsl_instance.send(symbol)).to eql(sub)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def dsl_hash(symbol, cls, keys = %w(sub1 sub2), &block)
        describe "##{symbol}" do
          it "should add an entry to the #{symbol} hash " \
             'and yield to the given block' do
            subs = keys.each_with_object({}) { |k, o| o[k] = double }
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(@dsl_instance.send(symbol)).to eql({})
            subs.each do |dsl_key, sub|
              expect(sub).to receive(:test).with no_args
              params = {}
              params = instance_exec(dsl_key, &block) if block_given?
              expect(cls).to receive(:new).with(
                dsl_key,
                **params
              ) { sub }
              @dsl_instance.send symbol, dsl_key, &:test
            end
            expect(@dsl_instance.send(symbol)).to eql(subs)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def dsl_array(symbol)
        describe "##{symbol}" do
          it "should add an entry to the #{symbol} array" do
            subs = %w(sub1 sub2)
            expect(@dsl_instance.send(symbol)).to eql([])
            subs.each do |value|
              @dsl_instance.send symbol, value
            end
            expect(@dsl_instance.send(symbol)).to eql(subs)
          end
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def dsl_block_array(symbol, cls)
        describe "##{symbol}" do
          it "should add an entry to the #{symbol} array " \
             'and yield to the given block' do
            subs = [double, double]
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(@dsl_instance.send(symbol)).to eql([])
            subs.each do |sub|
              expect(sub).to receive(:test).with no_args
              expect(cls).to receive(:new).with(
                no_args
              ) { sub }
              @dsl_instance.send symbol, &:test
            end
            expect(@dsl_instance.send(symbol)).to eql(subs)
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
