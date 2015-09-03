group :test, halt_on_fail: true do
  guard :rubocop do
    watch(/.+\.rb$/)
    watch(/.+\.gemspec$/)
    watch(/^Rakefile$/)
    watch(/^Gemfile$/)
    watch(/^Guardfile$/)
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
    watch(%r{(?:.+/)?\.rubocop_todo\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard :rspec, cmd: 'bundle exec rspec' do
    require 'guard/rspec/dsl'
    dsl = Guard::RSpec::Dsl.new(self)

    # RSpec files
    rspec = dsl.rspec
    watch(rspec.spec_helper) { rspec.spec_dir }
    watch(rspec.spec_support) { rspec.spec_dir }
    watch(rspec.spec_files)

    # Ruby files
    ruby = dsl.ruby
    dsl.watch_spec_files_for(ruby.lib_files)
  end

  guard 'cucumber', cli: '--profile default' do
    watch(%r{^lib/.+$}) { 'features' }
    watch(%r{^features/.+\.rb$}) { 'features' }
    watch(%r{^features/.+\.feature$})
  end
end

guard 'livereload' do
  watch(%r{.yardoc/.+$})
end

guard 'yard' do
  watch(%r{lib/.+\.rb})
  watch(%r{features/.+\.rb})
  watch(%r{features/.+\.feature})
  watch(%r{[^/]+.md})
end
