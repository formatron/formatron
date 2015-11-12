class Formatron
  module Support
    # utilities for testing generated DSL classes
    # rubocop:disable Metrics/ModuleLength
    module DSLTest
      def dsl_before_block(param_symbols = [])
        before :each do
          @dsl_params = param_symbols.each_with_object({}) do |s, p|
            p[s] = s.to_s
          end
          @dsl_instance = described_class.new params: @dsl_params
        end
      end

      def dsl_before_hash(param_symbols = [])
        before :each do
          @dsl_params = param_symbols.each_with_object({}) do |s, p|
            p[s] = s.to_s
          end
          @dsl_instance = described_class.new(
            dsl_key: 'dsl_key', params: @dsl_params
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
      def dsl_block(symbol, cls, param_symbols = [])
        describe "##{symbol}" do
          it "should set the #{symbol} and yield to the given block" do
            sub = double
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(sub).to receive(:test).with no_args
            params = param_symbols.each_with_object({}) do |s, p|
              p[s] = @dsl_params[s]
            end
            expect(cls).to receive(:new).with(
              params: params
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
      def dsl_hash(symbol, cls, param_symbols = [])
        describe "##{symbol}" do
          it "should add an entry to the #{symbol} hash " \
             'and yield to the given block' do
            subs = {
              'sub1' => double,
              'sub2' => double
            }
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(@dsl_instance.send(symbol)).to eql({})
            params = param_symbols.each_with_object({}) do |s, p|
              p[s] = @dsl_params[s]
            end
            subs.each do |dsl_key, sub|
              expect(sub).to receive(:test).with no_args
              expect(cls).to receive(:new).with(
                dsl_key: dsl_key,
                params: params
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
      def dsl_block_array(symbol, cls, param_symbols = [])
        describe "##{symbol}" do
          it "should add an entry to the #{symbol} array " \
             'and yield to the given block' do
            subs = [double, double]
            cls = class_double(
              described_class.const_get(cls).name
            ).as_stubbed_const
            expect(@dsl_instance.send(symbol)).to eql([])
            params = param_symbols.each_with_object({}) do |s, p|
              p[s] = @dsl_params[s]
            end
            subs.each do |sub|
              expect(sub).to receive(:test).with no_args
              expect(cls).to receive(:new).with(
                params: params
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
    # rubocop:enable Metrics/ModuleLength
  end
end
