class Formatron
  module Support
    # utilities for testing generated DSL classes
    module DSLTest
      def dsl_before_block
        before :each do
          @dsl_instance = described_class.new(
            parent: 'parent'
          )
        end
      end

      def dsl_before_hash
        before :each do
          @dsl_instance = described_class.new(
            parent: 'parent',
            key: 'key'
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
            expect(cls).to receive(
              :new
            ).with(parent: @dsl_instance) { sub }
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
      def dsl_hash(symbol, cls)
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
            subs.each do |key, sub|
              expect(sub).to receive(:test).with no_args
              expect(cls).to receive(:new).with(
                parent: @dsl_instance,
                key: key
              ) { sub }
              @dsl_instance.send symbol, key, &:test
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
            subs.each do |key|
              @dsl_instance.send symbol, key
            end
            expect(@dsl_instance.send(symbol)).to eql(subs)
          end
        end
      end
    end
  end
end
