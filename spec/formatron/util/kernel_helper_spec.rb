require 'spec_helper'
require 'formatron/util/kernel_helper'

describe Formatron::Util::KernelHelper do
  describe '::shell' do
    it 'should run the command and return the output' do
      output = Formatron::Util::KernelHelper.shell 'echo hello'
      expect(output).to eql "hello\n"
    end
  end

  describe '::success?' do
    context 'when a command succeeds' do
      before(:each) do
        Formatron::Util::KernelHelper.shell 'true'
      end

      it 'should return true' do
        expect(Formatron::Util::KernelHelper.success?).to eql true
      end
    end

    context 'when a command fails' do
      before(:each) do
        Formatron::Util::KernelHelper.shell 'false'
      end

      it 'should return false' do
        expect(Formatron::Util::KernelHelper.success?).to eql false
      end
    end
  end
end
