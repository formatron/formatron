require_relative 'dsl/formatron'

class Formatron
  # context for evaluating the Formatronfile
  class DSL
    attr_reader :formatron, :config, :target

    def initialize(file:, config:, target:, aws:, external:)
      @formatron = Formatron.new aws: aws, external: external
      @config = config
      @target = target
      instance_eval File.read(file), file
    end
  end
end
