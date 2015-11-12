require_relative 'dsl/formatron'

class Formatron
  # context for evaluating the Formatronfile
  class DSL
    attr_reader :formatron, :config, :target

    def initialize(file:, config:, target:, aws:)
      @formatron = Formatron.new params: { aws: aws }
      @config = config
      @target = target
      instance_eval File.read(file), file
    end
  end
end
