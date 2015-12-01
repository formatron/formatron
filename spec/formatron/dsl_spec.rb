require 'formatron/dsl'

# namespacing for tests
class Formatron
  describe DSL do
    include FakeFS::SpecHelpers

    it 'should load and evaluate the given file' do
      target = 'target'
      config = 'config'
      external = 'external'
      formatron = double
      expect(formatron).to receive(:target).with target
      expect(formatron).to receive(:config).with config
      formatron_class = class_double(
        'Formatron::DSL::Formatron'
      ).as_stubbed_const
      aws = instance_double 'Formatron::AWS'
      expect(formatron_class).to receive(:new).with(
        external: external,
        aws: aws
      ) { formatron }
      file = 'file'
      File.write file, <<-EOH
        formatron.target target
        formatron.config config
      EOH
      DSL.new(
        file: file,
        target: target,
        config: config,
        external: external,
        aws: aws
      )
    end
  end
end
