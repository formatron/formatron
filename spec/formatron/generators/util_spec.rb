require 'formatron/generators/util'

class Formatron
  # namespacing for tests
  module Generators
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

      describe '#databag_secret' do
        databag_secret = 'RJDY7W3TW99BMMBIVKGTRBUGW51MCYZC5121JA87'
        # rubocop:disable Metrics/LineLength
        random = 136_690_544_786_843_736_891_389_940_419_100_424_921_600_504_110_568_485_585_351_559
        # rubocop:enable Metrics/LineLength

        before :each do
          secure_random_class = class_double(
            'SecureRandom'
          ).as_stubbed_const
          allow(secure_random_class).to receive(:random_number).with(
            36**40
          ) { random }
        end

        it 'should generate a random 40 character string' do
          expect(Util.databag_secret).to eql databag_secret
        end
      end
    end
  end
end
