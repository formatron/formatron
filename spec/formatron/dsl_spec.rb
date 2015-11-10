require 'formatron/dsl'

# namespacing for tests
class Formatron
  describe DSL do
    include FakeFS::SpecHelpers

    it 'should load and evaluate the given file' do
      target = 'target'
      config = 'config'
      formatron = double
      expect(formatron).to receive(:target).with target
      expect(formatron).to receive(:config).with config
      formatron_class = class_double(
        'Formatron::DSL::Formatron'
      ).as_stubbed_const
      allow(formatron_class).to receive(:new) { formatron }
      file = 'file'
      File.write file, <<-EOH
        formatron.target target
        formatron.config config
      EOH
      DSL.new(
        file: file,
        target: target,
        config: config
      )
    end
  end
end
