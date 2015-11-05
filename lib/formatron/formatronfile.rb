require_relative 'formatronfile/bootstrap'
require_relative 'formatronfile/dependency'

class Formatron
  # DSL for the Formatronfile
  class Formatronfile
    attr_reader(
      :config,
      :target,
      :dependencies
    )

    def initialize(aws:, config:, target:, file:)
      @aws = aws
      @config = config
      @target = target
      @dependencies = {}
      instance_eval File.read(file), file
    end

    def name(value = nil)
      @name = value unless value.nil?
      @name
    end

    def bucket(value = nil)
      @bucket = value unless value.nil?
      @bucket
    end

    def depends(dependency)
      @dependencies[dependency] = Dependency.new(
        aws: @aws,
        bucket: @bucket,
        target: @target,
        name: dependency
      )
    end

    def bootstrap
      @bootstrap ||= Bootstrap.new
      yield @bootstrap if block_given?
      @bootstrap
    end
  end
end
