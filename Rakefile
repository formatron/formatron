require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'coveralls/rake/task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop)

Coveralls::RakeTask.new

task :clean do
  rm_rf 'coverage'
end

task default: [:clean, :rubocop, :spec, 'coveralls:push']
