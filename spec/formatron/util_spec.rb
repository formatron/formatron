require 'formatron/util'

# namespacing for tests
class Formatron
  describe Util do
    describe '#guid' do
      guid = 'MRXJBBXL'
      random = 1_784_812_558_377

      before :each do
        random_class = class_double(
          'Random'
        ).as_stubbed_const
        allow(random_class).to receive(:rand).with(
          36**8
        ) { random }
      end

      it 'should generate a random 8 character string' do
        expect(Util.guid).to eql guid
      end
    end
  end
end
