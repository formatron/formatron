require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features'
end

RuboCop::RakeTask.new(:rubocop)

Coveralls::RakeTask.new

task :clean do
  rm_rf 'coverage'
end

task default: [:clean, :rubocop, :spec, :features, 'coveralls:push']
