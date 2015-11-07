require 'spec_helper'
require 'formatron/util/shell'

class Formatron
  # namespacing for tests
  module Util
    describe Shell do
      describe '::exec' do
        it 'should run the command and log the output' do
          expect(Formatron::LOG).to receive(:info).with 'hello'
          Shell.exec 'echo hello'
        end

        context 'when a command succeeds' do
          it 'should return true' do
            expect(Shell.exec 'true').to eql true
          end
        end

        context 'when a command fails' do
          it 'should return false' do
            expect(Shell.exec 'false').to eql false
          end
        end
      end
    end
  end
end
